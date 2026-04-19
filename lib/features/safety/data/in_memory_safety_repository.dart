import 'package:aktivite/core/config/sample_ids.dart';
import 'package:aktivite/features/safety/data/safety_repository.dart';

class InMemorySafetyRepository implements SafetyRepository {
  final Set<String> _blockedUserIds = <String>{};
  final Map<String, List<String>> _reportedReasonsByUser =
      <String, List<String>>{};

  Set<String> get blockedUserIds => Set<String>.unmodifiable(_blockedUserIds);

  Map<String, List<String>> get reportedReasonsByUser => {
        for (final entry in _reportedReasonsByUser.entries)
          entry.key: List<String>.unmodifiable(entry.value),
      };

  bool hasBlockedUser(String targetUserId) {
    return _blockedUserIds.contains(targetUserId.trim());
  }

  List<String> reportedReasonsFor(String targetUserId) {
    return List<String>.unmodifiable(
      _reportedReasonsByUser[targetUserId.trim()] ?? const <String>[],
    );
  }

  @override
  Future<void> blockUser({
    required String targetUserId,
  }) async {
    final normalizedUserId = targetUserId.trim();
    if (normalizedUserId.isEmpty || normalizedUserId == SampleIds.currentUser) {
      return;
    }
    _blockedUserIds.add(normalizedUserId);
  }

  @override
  Future<void> reportUser({
    required String targetUserId,
    required String reason,
  }) async {
    final normalizedUserId = targetUserId.trim();
    final normalizedReason = reason.trim();
    if (normalizedUserId.isEmpty ||
        normalizedUserId == SampleIds.currentUser ||
        normalizedReason.isEmpty) {
      return;
    }

    final reasons = _reportedReasonsByUser.putIfAbsent(
      normalizedUserId,
      () => <String>[],
    );
    if (!reasons.contains(normalizedReason)) {
      reasons.add(normalizedReason);
    }
  }
}
