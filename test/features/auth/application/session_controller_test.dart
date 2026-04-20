import 'dart:async';

import 'package:aktivite/core/config/sample_ids.dart';
import 'package:aktivite/features/auth/application/session_controller.dart';
import 'package:aktivite/features/auth/data/auth_repository.dart';
import 'package:aktivite/features/auth/data/phone_auth_result.dart';
import 'package:aktivite/shared/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository();

  final StreamController<String?> _controller =
      StreamController<String?>.broadcast();
  String? _currentUserId;

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
  Future<PhoneAuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _currentUserId = SampleIds.currentUser;
    _controller.add(_currentUserId);
    return const PhoneAuthResult.signedIn();
  }

  @override
  Future<PhoneAuthResult> signInWithGoogle() async {
    _currentUserId = SampleIds.currentUser;
    _controller.add(_currentUserId);
    return const PhoneAuthResult.signedIn();
  }

  @override
  Future<PhoneAuthResult> signInWithApple() async {
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

void main() {
  group('SessionController', () {
    test('syncs signed-in and signed-out state from auth repository', () async {
      final authRepository = _FakeAuthRepository();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
        ],
      );
      addTearDown(container.dispose);

      expect(
          container.read(sessionControllerProvider).isAuthenticated, isFalse);

      await container.read(sessionControllerProvider.notifier).signInDemo();
      await Future<void>.delayed(Duration.zero);

      final signedIn = container.read(sessionControllerProvider);
      expect(signedIn.isAuthenticated, isTrue);
      expect(signedIn.userId, SampleIds.currentUser);
      expect(signedIn.isOnboardingComplete, isFalse);

      container.read(sessionControllerProvider.notifier).completeOnboarding();
      expect(
        container.read(sessionControllerProvider).isOnboardingComplete,
        isTrue,
      );

      await container.read(sessionControllerProvider.notifier).signOut();
      await Future<void>.delayed(Duration.zero);

      final signedOut = container.read(sessionControllerProvider);
      expect(signedOut.isAuthenticated, isFalse);
      expect(signedOut.userId, isNull);
      expect(signedOut.isOnboardingComplete, isFalse);
    });

    test('confirmSmsCode forwards repository response', () async {
      final authRepository = _FakeAuthRepository();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
        ],
      );
      addTearDown(container.dispose);

      final result = await container
          .read(sessionControllerProvider.notifier)
          .confirmSmsCode(
            verificationId: 'verify-123',
            smsCode: '123456',
          );

      expect(result.isSignedIn, isTrue);
    });
  });
}
