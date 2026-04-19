import 'package:aktivite/core/constants/safety_report_reasons.dart';

String? normalizeSafetyCurrentUserId(String? currentUserId) {
  final normalizedCurrentUserId = currentUserId?.trim() ?? '';
  if (normalizedCurrentUserId.isEmpty) {
    return null;
  }
  return normalizedCurrentUserId;
}

String? normalizeSafetyTargetUserId(
  String targetUserId, {
  required String? currentUserId,
}) {
  final normalizedCurrentUserId = normalizeSafetyCurrentUserId(currentUserId);
  final normalizedTargetUserId = targetUserId.trim();
  if (normalizedCurrentUserId == null ||
      normalizedTargetUserId.isEmpty ||
      normalizedTargetUserId == normalizedCurrentUserId) {
    return null;
  }
  return normalizedTargetUserId;
}

String? normalizeSafetyReason(String reason) {
  return SafetyReportReasons.normalize(reason);
}

String? buildSafetyBlockDocumentId({
  required String targetUserId,
  required String? currentUserId,
}) {
  final normalizedCurrentUserId = normalizeSafetyCurrentUserId(currentUserId);
  final normalizedTargetUserId = normalizeSafetyTargetUserId(
    targetUserId,
    currentUserId: normalizedCurrentUserId,
  );
  if (normalizedCurrentUserId == null || normalizedTargetUserId == null) {
    return null;
  }
  return '$normalizedCurrentUserId-$normalizedTargetUserId';
}
