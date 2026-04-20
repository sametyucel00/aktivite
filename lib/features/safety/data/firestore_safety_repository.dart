import 'package:aktivite/core/config/firebase_collection_paths.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'safety_repository.dart';
import 'safety_action_normalizer.dart';

class FirestoreSafetyRepository implements SafetyRepository {
  FirestoreSafetyRepository({
    FirebaseAuth Function()? auth,
    FirebaseFirestore Function()? firestore,
  })  : _auth = auth ?? (() => FirebaseAuth.instance),
        _firestore = firestore ?? (() => FirebaseFirestore.instance);

  final FirebaseAuth Function() _auth;
  final FirebaseFirestore Function() _firestore;

  CollectionReference<Map<String, dynamic>> get _reports =>
      _firestore().collection(FirebaseCollectionPaths.reports);

  CollectionReference<Map<String, dynamic>> get _blocks =>
      _firestore().collection(FirebaseCollectionPaths.blocks);

  @override
  Stream<Set<String>> watchBlockedUserIds() {
    return _auth().authStateChanges().asyncExpand((user) {
      final userId = user?.uid;
      if (userId == null) {
        return Stream.value(const <String>{});
      }

      return _blocks
          .where(FirebaseDocumentFields.userId, isEqualTo: userId)
          .where(FirebaseDocumentFields.status, isEqualTo: 'active')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => doc.data()[FirebaseDocumentFields.targetUserId])
            .whereType<String>()
            .where((value) => value.trim().isNotEmpty)
            .map((value) => value.trim())
            .toSet();
      });
    });
  }

  @override
  Stream<Map<String, List<String>>> watchReportedReasonsByUser() {
    return _auth().authStateChanges().asyncExpand((user) {
      final userId = user?.uid;
      if (userId == null) {
        return Stream.value(const <String, List<String>>{});
      }

      return _reports
          .where(FirebaseDocumentFields.userId, isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
        final grouped = <String, Set<String>>{};
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final targetUserId =
              (data[FirebaseDocumentFields.targetUserId] as String?)?.trim();
          final reason =
              (data[FirebaseDocumentFields.reason] as String?)?.trim();
          if (targetUserId == null ||
              targetUserId.isEmpty ||
              reason == null ||
              reason.isEmpty) {
            continue;
          }
          grouped.putIfAbsent(targetUserId, () => <String>{}).add(reason);
        }

        return {
          for (final entry in grouped.entries)
            entry.key: entry.value.toList(growable: false),
        };
      });
    });
  }

  @override
  Future<void> reportUser({
    required String targetUserId,
    required String reason,
  }) async {
    final currentUserId = normalizeSafetyCurrentUserId(_currentUserId);
    final normalizedTargetUserId = normalizeSafetyTargetUserId(
      targetUserId,
      currentUserId: currentUserId,
    );
    final normalizedReason = normalizeSafetyReason(reason);
    if (normalizedTargetUserId == null || normalizedReason == null) {
      return;
    }

    await _reports.add({
      FirebaseDocumentFields.userId: currentUserId,
      FirebaseDocumentFields.targetUserId: normalizedTargetUserId,
      FirebaseDocumentFields.reason: normalizedReason,
      FirebaseDocumentFields.status: 'pendingReview',
      FirebaseDocumentFields.workflowSource: 'clientReport',
      FirebaseDocumentFields.createdAt: FieldValue.serverTimestamp(),
      FirebaseDocumentFields.updatedAt: FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> blockUser({
    required String targetUserId,
  }) async {
    final currentUserId = normalizeSafetyCurrentUserId(_currentUserId);
    final normalizedTargetUserId = normalizeSafetyTargetUserId(
      targetUserId,
      currentUserId: currentUserId,
    );
    final blockDocumentId = buildSafetyBlockDocumentId(
      targetUserId: targetUserId,
      currentUserId: currentUserId,
    );
    if (normalizedTargetUserId == null ||
        currentUserId == null ||
        blockDocumentId == null) {
      return;
    }

    await _blocks.doc(blockDocumentId).set({
      FirebaseDocumentFields.userId: currentUserId,
      FirebaseDocumentFields.targetUserId: normalizedTargetUserId,
      FirebaseDocumentFields.status: 'active',
      FirebaseDocumentFields.workflowSource: 'clientBlock',
      FirebaseDocumentFields.createdAt: FieldValue.serverTimestamp(),
      FirebaseDocumentFields.updatedAt: FieldValue.serverTimestamp(),
    });
  }

  String? get _currentUserId => _auth().currentUser?.uid;
}
