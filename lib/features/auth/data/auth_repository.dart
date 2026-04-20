import 'phone_auth_result.dart';

abstract class AuthRepository {
  Stream<String?> authStateChanges();

  Future<PhoneAuthResult> signInWithPhone({
    required String phoneNumber,
  });

  Future<PhoneAuthResult> confirmSmsCode({
    required String verificationId,
    required String smsCode,
  });

  Future<PhoneAuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return const PhoneAuthResult.unsupported();
  }

  Future<PhoneAuthResult> signInWithGoogle() async {
    return const PhoneAuthResult.unsupported();
  }

  Future<PhoneAuthResult> signInWithApple() async {
    return const PhoneAuthResult.unsupported();
  }

  Future<void> signOut();
}
