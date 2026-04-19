import 'dart:async';

import 'package:aktivite/core/config/sample_ids.dart';
import 'package:aktivite/features/auth/data/auth_repository.dart';
import 'package:aktivite/features/auth/data/phone_auth_result.dart';

class InMemoryAuthRepository implements AuthRepository {
  final StreamController<String?> _controller =
      StreamController<String?>.broadcast();
  String? _currentUserId;
  static const _demoVerificationId = 'demo-verification-id';
  static const _demoSmsCode = '123456';

  @override
  Stream<String?> authStateChanges() {
    return Stream<String?>.multi((multi) {
      multi.add(_currentUserId);
      final subscription = _controller.stream.listen(
        multi.add,
        onError: multi.addError,
        onDone: multi.close,
      );
      multi.onCancel = subscription.cancel;
    });
  }

  @override
  Future<PhoneAuthResult> signInWithPhone({
    required String phoneNumber,
  }) async {
    if (phoneNumber == '+90 555 000 0000') {
      _currentUserId = SampleIds.currentUser;
      _controller.add(_currentUserId);
      return const PhoneAuthResult.signedIn();
    }

    return const PhoneAuthResult.codeSent(
      verificationId: _demoVerificationId,
    );
  }

  @override
  Future<PhoneAuthResult> confirmSmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    if (verificationId != _demoVerificationId) {
      return const PhoneAuthResult.failed(
        failureReason: PhoneAuthFailureReason.sessionExpired,
      );
    }

    if (smsCode != _demoSmsCode) {
      return const PhoneAuthResult.failed(
        failureReason: PhoneAuthFailureReason.invalidCode,
      );
    }

    _currentUserId = SampleIds.currentUser;
    _controller.add(_currentUserId);
    return const PhoneAuthResult.signedIn();
  }

  @override
  Future<void> signOut() async {
    _currentUserId = null;
    _controller.add(null);
  }
}
