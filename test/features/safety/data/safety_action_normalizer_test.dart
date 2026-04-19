import 'package:aktivite/features/safety/data/safety_action_normalizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalizeSafetyCurrentUserId trims and rejects blank values', () {
    expect(normalizeSafetyCurrentUserId(null), isNull);
    expect(normalizeSafetyCurrentUserId('  '), isNull);
    expect(normalizeSafetyCurrentUserId(' user-1 '), 'user-1');
  });

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

  test('buildSafetyBlockDocumentId creates deterministic ids', () {
    expect(
      buildSafetyBlockDocumentId(
        targetUserId: ' guest-1 ',
        currentUserId: ' user-1 ',
      ),
      'user-1-guest-1',
    );
    expect(
      buildSafetyBlockDocumentId(
        targetUserId: 'user-1',
        currentUserId: 'user-1',
      ),
      isNull,
    );
  });
}
