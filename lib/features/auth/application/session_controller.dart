import 'package:aktivite/features/auth/data/auth_repository.dart';
import 'package:aktivite/features/auth/data/phone_auth_result.dart';
import 'package:aktivite/features/auth/domain/app_session.dart';
import 'package:aktivite/shared/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionController extends Notifier<AppSession> {
  bool _initialized = false;

  @override
  AppSession build() {
    if (!_initialized) {
      _initialized = true;
      _bindAuthState(ref.read(authRepositoryProvider));
    }
    return const AppSession.signedOut();
  }

  Future<PhoneAuthResult> signInDemo() {
    return ref.read(authRepositoryProvider).signInWithPhone(
          phoneNumber: '+90 555 000 0000',
        );
  }

  Future<PhoneAuthResult> signInWithPhone(String phoneNumber) {
    return ref.read(authRepositoryProvider).signInWithPhone(
          phoneNumber: phoneNumber,
        );
  }

  Future<PhoneAuthResult> confirmSmsCode({
    required String verificationId,
    required String smsCode,
  }) {
    return ref.read(authRepositoryProvider).confirmSmsCode(
          verificationId: verificationId,
          smsCode: smsCode,
        );
  }

  Future<PhoneAuthResult> signInWithEmail({
    required String email,
    required String password,
  }) {
    return ref.read(authRepositoryProvider).signInWithEmail(
          email: email,
          password: password,
        );
  }

  Future<PhoneAuthResult> signInWithGoogle() {
    return ref.read(authRepositoryProvider).signInWithGoogle();
  }

  Future<PhoneAuthResult> signInWithApple() {
    return ref.read(authRepositoryProvider).signInWithApple();
  }

  void completeOnboarding() {
    state = state.copyWith(isOnboardingComplete: true);
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
  }

  void _bindAuthState(AuthRepository repository) {
    final subscription = repository.authStateChanges().listen((userId) {
      if (userId == null) {
        state = const AppSession.signedOut();
        return;
      }

      final sameUser = state.userId == userId;
      state = state.copyWith(
        isAuthenticated: true,
        isOnboardingComplete: sameUser ? state.isOnboardingComplete : false,
        userId: userId,
      );
    });
    ref.onDispose(subscription.cancel);
  }
}

final sessionControllerProvider =
    NotifierProvider<SessionController, AppSession>(SessionController.new);
