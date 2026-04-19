import 'package:aktivite/core/config/sample_ids.dart';
import 'package:aktivite/features/safety/data/safety_repository.dart';

import 'safety_action_normalizer.dart';

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
    final normalizedUserId = normalizeSafetyTargetUserId(
      targetUserId,
      currentUserId: SampleIds.currentUser,
    );
    if (normalizedUserId == null) {
      return;
    }
    _blockedUserIds.add(normalizedUserId);
  }

  @override
  Future<void> reportUser({
    required String targetUserId,
    required String reason,
  }) async {
    final normalizedUserId = normalizeSafetyTargetUserId(
      targetUserId,
      currentUserId: SampleIds.currentUser,
    );
    final normalizedReason = normalizeSafetyReason(reason);
    if (normalizedUserId == null || normalizedReason == null) {
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
