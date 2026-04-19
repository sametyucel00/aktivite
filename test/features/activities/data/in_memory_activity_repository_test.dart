import 'package:aktivite/core/config/sample_ids.dart';
import 'package:aktivite/core/enums/activity_category.dart';
import 'package:aktivite/core/enums/activity_status.dart';
import 'package:aktivite/core/enums/discovery_surface.dart';
import 'package:aktivite/core/enums/plan_time_option.dart';
import 'package:aktivite/features/activities/data/in_memory_activity_repository.dart';
import 'package:aktivite/shared/models/activity_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InMemoryActivityRepository', () {
    test('watchNearbyPlans emits initial plans immediately', () async {
      final repository = InMemoryActivityRepository();

      final plans = await repository.watchNearbyPlans().first;

      expect(plans, isNotEmpty);
      expect(plans.map((plan) => plan.id), contains(SampleIds.coffeeActivity));
    });

    test('createPlan adds a plan to the stream snapshot', () async {
      final repository = InMemoryActivityRepository();
      final newPlan = ActivityPlan(
        id: 'activity-99',
        ownerUserId: SampleIds.currentUser,
        title: 'Board games tonight',
        category: ActivityCategory.games,
        description: 'Short casual game session.',
        city: 'Istanbul',
        approximateLocation: 'Kadikoy center',
        timeLabel: 'Tonight',
        timeOption: PlanTimeOption.tonight,
        scheduledAt: DateTime(2026, 4, 19, 20, 0),
        durationMinutes: 90,
        participantCount: 1,
        maxParticipants: 4,
        isIndoor: true,
        status: ActivityStatus.open,
        surfaces: [
          DiscoverySurface.tonight,
          DiscoverySurface.groups,
        ],
      );

      await repository.createPlan(newPlan);

      final plans = await repository.watchNearbyPlans().first;

      expect(plans.map((plan) => plan.id), contains('activity-99'));
    });

    test('incrementParticipantCount fills the plan when capacity is reached',
        () async {
      final repository = InMemoryActivityRepository();

      await repository.createPlan(
        ActivityPlan(
          id: 'activity-full',
          ownerUserId: SampleIds.currentUser,
          title: 'Coffee now',
          category: ActivityCategory.coffee,
          description: 'Quick meetup.',
          city: 'Istanbul',
          approximateLocation: 'Besiktas square',
          timeLabel: 'Now',
          timeOption: PlanTimeOption.now,
          scheduledAt: DateTime(2026, 4, 19, 17, 0),
          durationMinutes: 45,
          participantCount: 1,
          maxParticipants: 2,
          isIndoor: true,
          status: ActivityStatus.open,
          surfaces: [
            DiscoverySurface.now,
            DiscoverySurface.nearby,
          ],
        ),
      );

      await repository.incrementParticipantCount('activity-full');

      final plans = await repository.watchNearbyPlans().first;
      final updated = plans.singleWhere((plan) => plan.id == 'activity-full');

      expect(updated.participantCount, 2);
      expect(updated.status, ActivityStatus.full);
    });

    test('createPlan keeps duration and approximate location fields', () async {
      final repository = InMemoryActivityRepository();

      await repository.createPlan(
        ActivityPlan(
          id: 'activity-metadata',
          ownerUserId: SampleIds.currentUser,
          title: 'Evening walk',
          category: ActivityCategory.walk,
          description: 'Easy walk and chat.',
          city: 'Istanbul',
          approximateLocation: 'Caddebostan coast',
          timeLabel: 'Tonight',
          timeOption: PlanTimeOption.tonight,
          scheduledAt: DateTime(2026, 4, 19, 18, 30),
          durationMinutes: 60,
          participantCount: 1,
          maxParticipants: 3,
          isIndoor: false,
          status: ActivityStatus.open,
          surfaces: [
            DiscoverySurface.tonight,
            DiscoverySurface.nearby,
          ],
        ),
      );

      final plans = await repository.watchNearbyPlans().first;
      final created =
          plans.singleWhere((plan) => plan.id == 'activity-metadata');

      expect(created.approximateLocation, 'Caddebostan coast');
      expect(created.durationMinutes, 60);
    });

    test('incrementParticipantCount ignores unknown activity ids', () async {
      final repository = InMemoryActivityRepository();

      await repository.incrementParticipantCount('missing-activity');

      final plans = await repository.watchNearbyPlans().first;

      expect(plans.map((plan) => plan.id), isNot(contains('missing-activity')));
      expect(plans.length, 3);
    });
  });
}
