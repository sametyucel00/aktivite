import 'package:aktivite/features/profile/data/in_memory_profile_repository.dart';
import 'package:aktivite/shared/models/app_user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InMemoryProfileRepository', () {
    test('watchCurrentProfile emits initial seeded profile', () async {
      final repository = InMemoryProfileRepository();

      await expectLater(
        repository.watchCurrentProfile(),
        emits(
          isA<AppUserProfile>().having(
            (profile) => profile.displayName,
            'displayName',
            'Deniz',
          ),
        ),
      );
    });
  });
}
