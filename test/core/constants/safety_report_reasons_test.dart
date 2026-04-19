import 'package:aktivite/core/constants/safety_report_reasons.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SafetyReportReasons', () {
    test('normalize maps supported labels to canonical codes', () {
      expect(SafetyReportReasons.normalize(' Spam '), SafetyReportReasons.spam);
      expect(
        SafetyReportReasons.normalize('Unsafe meetup behavior'),
        SafetyReportReasons.unsafeMeetup,
      );
      expect(
        SafetyReportReasons.normalize('fake_profile'),
        SafetyReportReasons.fakeProfile,
      );
    });

    test('normalize rejects unsupported custom values', () {
      expect(SafetyReportReasons.normalize('custom reason'), isNull);
    });
  });
}
