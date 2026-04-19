import 'package:aktivite/core/config/sample_ids.dart';
import 'package:aktivite/core/enums/activity_category.dart';
import 'package:aktivite/core/enums/activity_status.dart';
import 'package:aktivite/core/enums/availability_slot.dart';
import 'package:aktivite/core/enums/discovery_surface.dart';
import 'package:aktivite/core/enums/group_preference.dart';
import 'package:aktivite/core/enums/social_mood.dart';
import 'package:aktivite/core/enums/verification_level.dart';
import 'package:aktivite/shared/models/activity_plan.dart';
import 'package:aktivite/shared/models/app_user_profile.dart';
import 'package:aktivite/shared/providers/app_providers.dart';
import 'package:aktivite/shared/widgets/join_plan_action.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_helpers/test_harness.dart';

void main() {
  testWidgets(
    'shows disabled profile-gate CTA when profile completion blocks joining',
    (tester) async {
      final plan = ActivityPlan(
        id: 'activity-1',
        ownerUserId: SampleIds.guestOne,
        title: 'Coffee',
        category: ActivityCategory.coffee,
        description: 'Simple coffee plan',
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

      await pumpTestApp(
        tester,
        child: JoinPlanAction(
          plan: plan,
          analyticsEventName: 'join_request_submitted',
        ),
        overrides: [
          currentUserProfileProvider.overrideWith(
            (ref) => Stream.value(
              const AppUserProfile(
                id: SampleIds.currentUser,
                displayName: 'Test',
                profilePhotoUrl: '',
                city: 'Istanbul',
                bio: 'Low completion',
                profileCompletion: 40,
                favoriteActivities: [ActivityCategory.coffee],
                activeTimes: <AvailabilitySlot>[],
                groupPreference: GroupPreference.flexible,
                socialMood: SocialMood.calm,
                verificationLabel: 'phone',
                verificationLevel: VerificationLevel.phone,
              ),
            ),
          ),
          joinRequestsProvider(plan.id).overrideWith(
            (ref) => Stream.value(const []),
          ),
        ],
      );

      expect(find.text('Add a few details'), findsOneWidget);
      expect(
        find.textContaining('Add a few more profile details'),
        findsOneWidget,
      );
    },
  );
}
