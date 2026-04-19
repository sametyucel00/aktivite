import 'package:aktivite/core/enums/activity_category.dart';
import 'package:aktivite/core/enums/activity_status.dart';
import 'package:aktivite/core/enums/discovery_surface.dart';
import 'package:aktivite/shared/models/activity_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('activity plan helpers expose invariants and joinability', () {
    final plan = ActivityPlan(
      id: 'plan-1',
      ownerUserId: 'owner-1',
      title: 'Coffee',
      category: ActivityCategory.coffee,
      description: 'Simple coffee',
      city: 'Istanbul',
      approximateLocation: 'Kadikoy',
      timeLabel: 'Tonight',
      scheduledAt: DateTime(2026, 4, 19, 19),
      durationMinutes: 60,
      participantCount: 1,
      maxParticipants: 4,
      isIndoor: true,
      status: ActivityStatus.open,
      surfaces: const [DiscoverySurface.tonight],
    );

    expect(plan.hasValidIdentity, isTrue);
    expect(plan.hasValidCreateDetails, isTrue);
    expect(plan.canAcceptJoinRequests, isTrue);
    expect(
      plan.copyWith(participantCount: 4).canAcceptJoinRequests,
      isFalse,
    );
  });
}
