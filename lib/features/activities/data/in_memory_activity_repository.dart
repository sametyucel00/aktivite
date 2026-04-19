import 'dart:async';

import 'package:aktivite/core/config/sample_ids.dart';
import 'package:aktivite/core/enums/activity_category.dart';
import 'package:aktivite/core/enums/activity_status.dart';
import 'package:aktivite/core/enums/discovery_surface.dart';
import 'package:aktivite/core/enums/plan_time_option.dart';
import 'package:aktivite/features/activities/data/activity_repository.dart';
import 'package:aktivite/shared/models/activity_plan.dart';

class InMemoryActivityRepository implements ActivityRepository {
  InMemoryActivityRepository() {
    _controller.add(_snapshot());
  }

  final List<ActivityPlan> _plans = [
    ActivityPlan(
      id: SampleIds.coffeeActivity,
      ownerUserId: SampleIds.guestOne,
      title: 'Coffee after work',
      category: ActivityCategory.coffee,
      description: 'A relaxed coffee meetup near the ferry around 19:00.',
      city: 'Istanbul',
      approximateLocation: 'Kadikoy ferry area',
      timeLabel: 'Tonight',
      timeOption: PlanTimeOption.tonight,
      scheduledAt: DateTime(2026, 4, 19, 19, 0),
      durationMinutes: 75,
      participantCount: 2,
      maxParticipants: 4,
      isIndoor: true,
      status: ActivityStatus.open,
      surfaces: [
        DiscoverySurface.tonight,
        DiscoverySurface.nearby,
      ],
    ),
    ActivityPlan(
      id: SampleIds.walkActivity,
      ownerUserId: SampleIds.guestTwo,
      title: 'Walking by the coast',
      category: ActivityCategory.walk,
      description: 'Easy pace, fresh air, and a simple chat.',
      city: 'Istanbul',
      approximateLocation: 'Moda coast',
      timeLabel: 'Now',
      timeOption: PlanTimeOption.now,
      scheduledAt: DateTime(2026, 4, 19, 16, 30),
      durationMinutes: 60,
      participantCount: 3,
      maxParticipants: 5,
      isIndoor: false,
      status: ActivityStatus.open,
      surfaces: [
        DiscoverySurface.now,
        DiscoverySurface.nearby,
        DiscoverySurface.groups,
      ],
    ),
    ActivityPlan(
      id: SampleIds.coworkActivity,
      ownerUserId: SampleIds.guestThree,
      title: 'Cowork session',
      category: ActivityCategory.cowork,
      description: 'Quiet cafe, focused work block, optional short break.',
      city: 'Kadikoy',
      approximateLocation: 'Yeldegirmeni cafe area',
      timeLabel: 'This afternoon',
      scheduledAt: DateTime(2026, 4, 19, 14, 0),
      durationMinutes: 120,
      participantCount: 1,
      maxParticipants: 3,
      isIndoor: true,
      status: ActivityStatus.open,
      surfaces: [
        DiscoverySurface.nearby,
      ],
    ),
  ];
  final StreamController<List<ActivityPlan>> _controller =
      StreamController<List<ActivityPlan>>.broadcast();

  @override
  Future<void> createPlan(ActivityPlan plan) async {
    _plans.add(plan);
    _controller.add(_snapshot());
  }

  @override
  Future<void> incrementParticipantCount(String activityId) async {
    final index = _plans.indexWhere((plan) => plan.id == activityId);
    if (index < 0) {
      return;
    }

    final current = _plans[index];
    final nextCount = (current.participantCount + 1).clamp(
      0,
      current.maxParticipants,
    );
    final updated = current.copyWith(participantCount: nextCount);
    _plans[index] = updated.copyWith(
      status: updated.isFull ? ActivityStatus.full : updated.status,
    );
    _controller.add(_snapshot());
  }

  @override
  Stream<List<ActivityPlan>> watchNearbyPlans() {
    return Stream<List<ActivityPlan>>.multi((multi) {
      multi.add(_snapshot());
      final subscription = _controller.stream.listen(
        multi.add,
        onError: multi.addError,
        onDone: multi.close,
      );
      multi.onCancel = subscription.cancel;
    });
  }

  List<ActivityPlan> _snapshot() => List<ActivityPlan>.unmodifiable(_plans);
}
