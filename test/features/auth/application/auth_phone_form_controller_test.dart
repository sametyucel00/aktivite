import 'dart:async';

import 'package:aktivite/core/config/sample_ids.dart';
import 'package:aktivite/features/auth/application/auth_phone_form_controller.dart';
import 'package:aktivite/features/auth/application/session_controller.dart';
import 'package:aktivite/features/auth/data/auth_repository.dart';
import 'package:aktivite/features/auth/data/phone_auth_result.dart';
import 'package:aktivite/shared/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingAuthRepository implements AuthRepository {
  final StreamController<String?> _controller =
      StreamController<String?>.broadcast();
  String? _currentUserId;
  String? lastPhoneNumber;

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
  Future<PhoneAuthResult> signInWithPhone({required String phoneNumber}) async {
    lastPhoneNumber = phoneNumber;
    _currentUserId = SampleIds.currentUser;
    _controller.add(_currentUserId);
    return const PhoneAuthResult.signedIn();
  }

  @override
  Future<PhoneAuthResult> confirmSmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
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

class _UnsupportedAuthRepository implements AuthRepository {
  @override
  Stream<String?> authStateChanges() => Stream<String?>.value(null);

  @override
  Future<PhoneAuthResult> signInWithPhone({required String phoneNumber}) {
    return Future<PhoneAuthResult>.value(
      const PhoneAuthResult.unsupported(),
    );
  }

  @override
  Future<PhoneAuthResult> confirmSmsCode({
    required String verificationId,
    required String smsCode,
  }) {
    return Future<PhoneAuthResult>.value(
      const PhoneAuthResult.unsupported(),
    );
  }

  @override
  Future<void> signOut() async {}
}

class _CodeSentAuthRepository implements AuthRepository {
  int signInAttempts = 0;

  @override
  Stream<String?> authStateChanges() => Stream<String?>.value(null);

  @override
  Future<PhoneAuthResult> signInWithPhone({required String phoneNumber}) {
    signInAttempts += 1;
    return Future<PhoneAuthResult>.value(
      PhoneAuthResult.codeSent(verificationId: 'verify-$signInAttempts'),
    );
  }

  @override
  Future<PhoneAuthResult> confirmSmsCode({
    required String verificationId,
    required String smsCode,
  }) {
    if (smsCode == '123456') {
      return Future<PhoneAuthResult>.value(
        const PhoneAuthResult.signedIn(),
      );
    }

    return Future<PhoneAuthResult>.value(
      const PhoneAuthResult.failed(
        failureReason: PhoneAuthFailureReason.invalidCode,
      ),
    );
  }

  @override
  Future<void> signOut() async {}
}

void main() {
  group('AuthPhoneFormController', () {
    test('validatePhoneNumber handles empty and invalid values', () {
      expect(validatePhoneNumber(''), AuthPhoneFormError.empty);
      expect(validatePhoneNumber('12345'), AuthPhoneFormError.invalid);
      expect(validatePhoneNumber('+90 555 000 00 00'), isNull);
    });

    test('normalizePhoneNumber trims separators and preserves leading plus',
        () {
      expect(
        normalizePhoneNumber(' +90 (555) 000 00 00 '),
        '+905550000000',
      );
      expect(
        normalizePhoneNumber('0090 555 000 00 00'),
        '+905550000000',
      );
    });

    test('validateSmsCode requires six digits', () {
      expect(validateSmsCode(''), AuthPhoneFormError.codeEmpty);
      expect(validateSmsCode('12 34'), AuthPhoneFormError.codeInvalid);
      expect(validateSmsCode('123456'), isNull);
    });

    test('submit sends normalized phone number through session flow', () async {
      final authRepository = _RecordingAuthRepository();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
        ],
      );
      addTearDown(container.dispose);

      final controller =
          container.read(authPhoneFormControllerProvider.notifier);

      controller.setPhoneNumber(' +90 (555) 000 00 00 ');
      final success = await controller.submit();
      await Future<void>.delayed(Duration.zero);

      expect(success, isTrue);
      expect(authRepository.lastPhoneNumber, '+905550000000');
      expect(
        container.read(sessionControllerProvider).userId,
        SampleIds.currentUser,
      );
    });

    test('submit maps unsupported verification flows to controller error',
        () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider
              .overrideWithValue(_UnsupportedAuthRepository()),
        ],
      );
      addTearDown(container.dispose);

      final controller =
          container.read(authPhoneFormControllerProvider.notifier);

      controller.setPhoneNumber('+90 555 000 00 00');
      final success = await controller.submit();

      expect(success, isFalse);
      expect(
        container.read(authPhoneFormControllerProvider).error,
        AuthPhoneFormError.unsupported,
      );
    });

    test('submit keeps pending verification id when code is sent', () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(_CodeSentAuthRepository()),
        ],
      );
      addTearDown(container.dispose);

      final controller =
          container.read(authPhoneFormControllerProvider.notifier);

      controller.setPhoneNumber('+90 555 000 00 00');
      final success = await controller.submit();

      expect(success, isFalse);
      expect(
        container.read(authPhoneFormControllerProvider).pendingVerificationId,
        'verify-1',
      );
      expect(
        container.read(authPhoneFormControllerProvider).error,
        isNull,
      );
    });

    test('resendCode refreshes pending verification id', () async {
      final authRepository = _CodeSentAuthRepository();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
        ],
      );
      addTearDown(container.dispose);

      final controller =
          container.read(authPhoneFormControllerProvider.notifier);

      controller.setPhoneNumber('+90 555 000 00 00');
      await controller.submit();
      final resent = await controller.resendCode();

      expect(resent, isFalse);
      expect(authRepository.signInAttempts, 2);
      expect(
        container.read(authPhoneFormControllerProvider).pendingVerificationId,
        'verify-2',
      );
    });

    test('submitCode signs in when verification code is valid', () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(_CodeSentAuthRepository()),
        ],
      );
      addTearDown(container.dispose);

      final controller =
          container.read(authPhoneFormControllerProvider.notifier);

      controller.setPhoneNumber('+90 555 000 00 00');
      await controller.submit();
      controller.setSmsCode('123456');
      final success = await controller.submitCode();

      expect(success, isTrue);
      expect(
        container.read(authPhoneFormControllerProvider).pendingVerificationId,
        isNull,
      );
    });

    test('submitCode maps invalid verification codes to controller error',
        () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(_CodeSentAuthRepository()),
        ],
      );
      addTearDown(container.dispose);

      final controller =
          container.read(authPhoneFormControllerProvider.notifier);

      controller.setPhoneNumber('+90 555 000 00 00');
      await controller.submit();
      controller.setSmsCode('000000');
      final success = await controller.submitCode();

      expect(success, isFalse);
      expect(
        container.read(authPhoneFormControllerProvider).error,
        AuthPhoneFormError.codeInvalid,
      );
    });
  });
}
