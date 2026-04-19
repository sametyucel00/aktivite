import 'package:aktivite/core/constants/safety_report_reasons.dart';

String? normalizeSafetyTargetUserId(
  String targetUserId, {
  required String? currentUserId,
}) {
  final normalizedTargetUserId = targetUserId.trim();
  if (currentUserId == null ||
      normalizedTargetUserId.isEmpty ||
      normalizedTargetUserId == currentUserId) {
    return null;
  }
  return normalizedTargetUserId;
}

String? normalizeSafetyReason(String reason) {
  return SafetyReportReasons.normalize(reason);
}
