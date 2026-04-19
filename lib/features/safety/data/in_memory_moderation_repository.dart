import 'dart:async';

import 'package:aktivite/core/config/sample_ids.dart';
import 'package:aktivite/core/utils/trust_event_factory.dart';
import 'package:aktivite/features/safety/data/moderation_repository.dart';
import 'package:aktivite/shared/models/moderation_event.dart';

class InMemoryModerationRepository implements ModerationRepository {
  InMemoryModerationRepository() {
    _controller.add(_snapshot());
  }

  final List<ModerationEvent> _events = [
    ModerationEvent(
      id: 'trust-1',
      subjectUserId: SampleIds.currentUser,
      reasonCode: TrustEventReasonCodes.phoneVerified,
      isUserVisible: false,
      createdAt: DateTime(2026, 4, 10, 18, 30),
    ),
    ModerationEvent(
      id: 'trust-2',
      subjectUserId: SampleIds.currentUser,
      reasonCode: TrustEventReasonCodes.safeMeetupReminderEnabled,
      isUserVisible: true,
      createdAt: DateTime(2026, 4, 12, 9, 15),
    ),
  ];
  final StreamController<List<ModerationEvent>> _controller =
      StreamController<List<ModerationEvent>>.broadcast();

  @override
  Future<void> createTrustEvent(ModerationEvent event) async {
    _events.add(event);
    _controller.add(_snapshot());
  }

  @override
  Stream<List<ModerationEvent>> watchTrustEvents(String userId) {
    return Stream<List<ModerationEvent>>.multi((multi) {
      multi.add(_eventsForUser(userId));
      final subscription = _controller.stream
          .map((events) => _eventsForUser(userId, events: events))
          .listen(
            multi.add,
            onError: multi.addError,
            onDone: multi.close,
          );
      multi.onCancel = subscription.cancel;
    });
  }

  List<ModerationEvent> _eventsForUser(
    String userId, {
    List<ModerationEvent>? events,
  }) {
    return (events ?? _events)
        .where((event) => event.subjectUserId == userId)
        .toList(growable: false);
  }

  List<ModerationEvent> _snapshot() =>
      List<ModerationEvent>.unmodifiable(_events);
}
