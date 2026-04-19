import 'package:aktivite/features/safety/data/in_memory_safety_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InMemorySafetyRepository', () {
    test('blockUser stores unique normalized blocked ids', () async {
      final repository = InMemorySafetyRepository();

      await repository.blockUser(targetUserId: ' guest-1 ');
      await repository.blockUser(targetUserId: 'guest-1');
      await repository.blockUser(targetUserId: '   ');

      expect(repository.blockedUserIds, {'guest-1'});
      expect(repository.hasBlockedUser('guest-1'), isTrue);
      expect(repository.hasBlockedUser(' guest-1 '), isTrue);
    });

    test('reportUser stores normalized unique reasons per user', () async {
      final repository = InMemorySafetyRepository();

      await repository.reportUser(
        targetUserId: ' guest-2 ',
        reason: ' Spam ',
      );
      await repository.reportUser(
        targetUserId: 'guest-2',
        reason: 'Spam',
      );
      await repository.reportUser(
        targetUserId: 'guest-2',
        reason: 'Unsafe meetup behavior',
      );
      await repository.reportUser(
        targetUserId: 'guest-2',
        reason: '   ',
      );

      expect(
        repository.reportedReasonsFor('guest-2'),
        ['Spam', 'Unsafe meetup behavior'],
      );
    });

    test('reportedReasonsByUser returns an immutable snapshot', () async {
      final repository = InMemorySafetyRepository();

      await repository.reportUser(
        targetUserId: 'guest-3',
        reason: 'Harassment',
      );

      final snapshot = repository.reportedReasonsByUser;

      expect(snapshot['guest-3'], ['Harassment']);
      expect(() => snapshot['guest-3']!.add('Extra'), throwsUnsupportedError);
    });
  });
}
