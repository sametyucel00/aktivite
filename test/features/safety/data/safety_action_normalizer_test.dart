import 'package:aktivite/features/safety/data/safety_action_normalizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalizeSafetyTargetUserId rejects blank and self values', () {
    expect(
      normalizeSafetyTargetUserId('  ', currentUserId: 'user-1'),
      isNull,
    );
    expect(
      normalizeSafetyTargetUserId('user-1', currentUserId: 'user-1'),
      isNull,
    );
    expect(
      normalizeSafetyTargetUserId(' guest-1 ', currentUserId: 'user-1'),
      'guest-1',
    );
  });

  test('normalizeSafetyReason only allows canonical reasons', () {
    expect(normalizeSafetyReason(' Harassment '), 'harassment');
    expect(normalizeSafetyReason('unsupported'), isNull);
  });
}
