abstract class SafetyRepository {
  Future<void> reportUser({
    required String targetUserId,
    required String reason,
  });

  Future<void> blockUser({
    required String targetUserId,
  });
}
