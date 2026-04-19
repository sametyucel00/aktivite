import 'package:aktivite/core/config/sample_ids.dart';
import 'package:aktivite/features/auth/data/in_memory_auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InMemoryAuthRepository', () {
    test('authStateChanges emits initial signed-out state', () async {
      final repository = InMemoryAuthRepository();
      final emitted = <String?>[];
      final subscription = repository.authStateChanges().listen(emitted.add);
      addTearDown(subscription.cancel);

      await Future<void>.delayed(Duration.zero);

      expect(emitted, [null]);
    });

    test('signInWithPhone emits current sample user and signOut emits null',
        () async {
      final repository = InMemoryAuthRepository();
      final emitted = <String?>[];
      final subscription = repository.authStateChanges().listen(emitted.add);
      addTearDown(subscription.cancel);

      await Future<void>.delayed(Duration.zero);

      final result =
          await repository.signInWithPhone(phoneNumber: '+90 555 000 0000');
      await Future<void>.delayed(Duration.zero);
      await repository.signOut();
      await Future<void>.delayed(Duration.zero);

      expect(result.isSignedIn, isTrue);
      expect(emitted, [
        null,
        SampleIds.currentUser,
        null,
      ]);
    });

    test('confirmSmsCode signs in after codeSent flow for non-demo phone',
        () async {
      final repository = InMemoryAuthRepository();
      final result =
          await repository.signInWithPhone(phoneNumber: '+90 555 111 11 11');

      expect(result.isCodeSent, isTrue);

      final confirmResult = await repository.confirmSmsCode(
        verificationId: result.verificationId!,
        smsCode: '123456',
      );

      expect(confirmResult.isSignedIn, isTrue);
    });
  });
}
