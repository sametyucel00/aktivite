import 'package:aktivite/shared/models/activity_plan.dart';

abstract class ActivityRepository {
  Stream<List<ActivityPlan>> watchNearbyPlans();

  Future<void> createPlan(ActivityPlan plan);

  Future<void> incrementParticipantCount(String activityId);

  Future<void> applyBoost({
    required String activityId,
    required DateTime expiresAt,
    int boostLevel = 1,
  });
}
