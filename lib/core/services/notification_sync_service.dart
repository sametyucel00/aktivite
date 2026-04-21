import 'dart:async';

import 'package:aktivite/core/config/firebase_collection_paths.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationSyncService {
  NotificationSyncService({
    FirebaseFirestore Function()? firestore,
    FirebaseMessaging Function()? messaging,
  })  : _firestore = firestore ?? (() => FirebaseFirestore.instance),
        _messaging = messaging ?? (() => FirebaseMessaging.instance);

  final FirebaseFirestore Function() _firestore;
  final FirebaseMessaging Function() _messaging;
  StreamSubscription<String>? _tokenRefreshSubscription;
  String? _activeUserId;

  Future<void> syncForUser(String userId) async {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) {
      return;
    }

    if (_activeUserId == normalizedUserId &&
        _tokenRefreshSubscription != null) {
      return;
    }

    await dispose();
    _activeUserId = normalizedUserId;

    await _requestPermissionIfNeeded();
    await _syncCurrentToken(normalizedUserId);

    _tokenRefreshSubscription = _messaging().onTokenRefresh.listen(
          (token) => _upsertToken(
            userId: normalizedUserId,
            token: token,
          ),
        );
  }

  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
    _activeUserId = null;
  }

  Future<void> _requestPermissionIfNeeded() async {
    try {
      await _messaging().requestPermission();
    } catch (_) {
      // Ignore unsupported or denied permission requests and keep the app usable.
    }
  }

  Future<void> _syncCurrentToken(String userId) async {
    try {
      final token = await _messaging().getToken();
      await _upsertToken(userId: userId, token: token);
    } catch (_) {
      // Web and desktop may not expose a token in every environment.
    }
  }

  Future<void> _upsertToken({
    required String userId,
    required String? token,
  }) async {
    final normalizedToken = token?.trim() ?? '';
    if (normalizedToken.isEmpty) {
      return;
    }

    await _firestore()
        .collection(FirebaseCollectionPaths.users)
        .doc(userId)
        .collection(FirebaseCollectionPaths.notificationTokens)
        .doc(_tokenDocumentId(normalizedToken))
        .set({
      'token': normalizedToken,
      'platform': _platformName(),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  String _platformName() {
    if (kIsWeb) {
      return 'web';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.linux:
        return 'linux';
      case TargetPlatform.fuchsia:
        return 'fuchsia';
    }
  }

  String _tokenDocumentId(String token) {
    return token.hashCode.abs().toString();
  }
}
