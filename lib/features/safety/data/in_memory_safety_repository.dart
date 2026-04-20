import 'dart:async';

import 'package:aktivite/core/config/sample_ids.dart';
import 'package:aktivite/features/safety/data/safety_repository.dart';

import 'safety_action_normalizer.dart';

class InMemorySafetyRepository implements SafetyRepository {
  InMemorySafetyRepository() {
    _controller.add(null);
  }

  final Set<String> _blockedUserIds = <String>{};
  final Map<String, List<String>> _reportedReasonsByUser =
      <String, List<String>>{};
  final StreamController<void> _controller = StreamController<void>.broadcast();

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
  Stream<Set<String>> watchBlockedUserIds() {
    return Stream<Set<String>>.multi((multi) {
      multi.add(blockedUserIds);
      final subscription = _controller.stream.listen((_) {
        multi.add(blockedUserIds);
      }, onError: multi.addError, onDone: multi.close);
      multi.onCancel = subscription.cancel;
    });
  }

  @override
  Stream<Map<String, List<String>>> watchReportedReasonsByUser() {
    return Stream<Map<String, List<String>>>.multi((multi) {
      multi.add(reportedReasonsByUser);
      final subscription = _controller.stream.listen((_) {
        multi.add(reportedReasonsByUser);
      }, onError: multi.addError, onDone: multi.close);
      multi.onCancel = subscription.cancel;
    });
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
    _controller.add(null);
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
    _controller.add(null);
  }
}
