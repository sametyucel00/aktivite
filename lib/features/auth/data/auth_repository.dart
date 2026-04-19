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

  Future<void> signOut();
}
