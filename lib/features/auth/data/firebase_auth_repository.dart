import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_repository.dart';
import 'phone_auth_result.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth Function()? auth,
  }) : _auth = auth ?? (() => FirebaseAuth.instance);

  final FirebaseAuth Function() _auth;

  @override
  Stream<String?> authStateChanges() {
    return _auth().authStateChanges().map((user) => user?.uid);
  }

  @override
  Future<PhoneAuthResult> signInWithPhone({
    required String phoneNumber,
  }) async {
    if (kIsWeb) {
      return const PhoneAuthResult.unsupported(
        message: 'Web phone auth requires a reCAPTCHA-backed verification UI.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return _verifyPhoneNumber(phoneNumber);
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return const PhoneAuthResult.unsupported(
          message:
              'Phone verification is currently wired for Android and iOS only.',
        );
    }
  }

  @override
  Future<PhoneAuthResult> confirmSmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await _auth().signInWithCredential(credential);
      return const PhoneAuthResult.signedIn();
    } on FirebaseAuthException catch (error) {
      return PhoneAuthResult.failed(
        message: error.message,
        failureReason: _mapFailureReason(error.code),
      );
    } catch (error) {
      return PhoneAuthResult.failed(message: error.toString());
    }
  }

  @override
  Future<void> signOut() {
    return _auth().signOut();
  }

  Future<PhoneAuthResult> _verifyPhoneNumber(String phoneNumber) async {
    final completer = Completer<PhoneAuthResult>();

    await _auth().verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (credential) async {
        try {
          await _auth().signInWithCredential(credential);
          if (!completer.isCompleted) {
            completer.complete(const PhoneAuthResult.signedIn());
          }
        } catch (error) {
          if (!completer.isCompleted) {
            completer.complete(
              PhoneAuthResult.failed(message: error.toString()),
            );
          }
        }
      },
      verificationFailed: (error) {
        if (!completer.isCompleted) {
          completer.complete(
            PhoneAuthResult.failed(message: error.message),
          );
        }
      },
      codeSent: (verificationId, forceResendingToken) {
        if (!completer.isCompleted) {
          completer.complete(
            PhoneAuthResult.codeSent(verificationId: verificationId),
          );
        }
      },
      codeAutoRetrievalTimeout: (verificationId) {
        if (!completer.isCompleted) {
          completer.complete(
            PhoneAuthResult.codeSent(verificationId: verificationId),
          );
        }
      },
    );

    return completer.future;
  }

  PhoneAuthFailureReason _mapFailureReason(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return PhoneAuthFailureReason.invalidPhoneNumber;
      case 'invalid-verification-code':
        return PhoneAuthFailureReason.invalidCode;
      case 'session-expired':
        return PhoneAuthFailureReason.sessionExpired;
      case 'code-expired':
        return PhoneAuthFailureReason.expiredCode;
      case 'too-many-requests':
        return PhoneAuthFailureReason.tooManyRequests;
      default:
        return PhoneAuthFailureReason.unknown;
    }
  }
}
