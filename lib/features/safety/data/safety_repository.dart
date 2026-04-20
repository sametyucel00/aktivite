abstract class SafetyRepository {
  Stream<Set<String>> watchBlockedUserIds();

  Stream<Map<String, List<String>>> watchReportedReasonsByUser();

  Future<void> reportUser({
    required String targetUserId,
    required String reason,
  });

  Future<void> blockUser({
    required String targetUserId,
  });
}
