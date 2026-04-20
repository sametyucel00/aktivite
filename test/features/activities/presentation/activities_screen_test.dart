import 'package:aktivite/core/config/sample_ids.dart';
import 'package:aktivite/core/enums/activity_category.dart';
import 'package:aktivite/core/enums/activity_status.dart';
import 'package:aktivite/core/enums/availability_slot.dart';
import 'package:aktivite/core/enums/discovery_surface.dart';
import 'package:aktivite/core/enums/group_preference.dart';
import 'package:aktivite/core/enums/join_request_status.dart';
import 'package:aktivite/core/enums/social_mood.dart';
import 'package:aktivite/core/enums/verification_level.dart';
import 'package:aktivite/features/activities/presentation/activities_screen.dart';
import 'package:aktivite/shared/models/activity_plan.dart';
import 'package:aktivite/shared/models/app_user_profile.dart';
import 'package:aktivite/shared/models/join_request.dart';
import 'package:aktivite/shared/models/join_request_summary.dart';
import 'package:aktivite/shared/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test_helpers/test_harness.dart';

void main() {
  testWidgets(
    'sorts owner join requests with pending first and shows plan context',
    (tester) async {
      final plan = ActivityPlan(
        id: 'owned-plan',
        ownerUserId: SampleIds.currentUser,
        title: 'Owner coffee plan',
        category: ActivityCategory.coffee,
        description: 'Hosted by current user',
        city: 'Istanbul',
        approximateLocation: 'Moda',
        timeLabel: 'Tonight',
        scheduledAt: DateTime(2026, 4, 19, 20),
        durationMinutes: 90,
        participantCount: 1,
        maxParticipants: 4,
        isIndoor: true,
        status: ActivityStatus.open,
        surfaces: const [DiscoverySurface.tonight],
      );
      const requests = [
        JoinRequest(
          id: 'request-approved',
          activityId: 'owned-plan',
          requesterId: 'approved-user',
          message: 'Approved request',
          status: JoinRequestStatus.approved,
        ),
        JoinRequest(
          id: 'request-pending',
          activityId: 'owned-plan',
          requesterId: 'pending-user',
          message: 'Pending request',
          status: JoinRequestStatus.pending,
        ),
        JoinRequest(
          id: 'request-cancelled',
          activityId: 'owned-plan',
          requesterId: 'cancelled-user',
          message: 'Cancelled request',
          status: JoinRequestStatus.cancelled,
        ),
      ];

      await pumpTestApp(
        tester,
        child: const ActivitiesScreen(),
        overrides: [
          ownedPlansProvider.overrideWith((ref) => AsyncValue.data([plan])),
          primaryOwnedPlanProvider.overrideWith((ref) => plan),
          ownedJoinRequestsByActivityProvider.overrideWith(
            (ref) => const AsyncValue.data({
              'owned-plan': requests,
            }),
          ),
          joinRequestSummaryProvider.overrideWith(
            (ref) => const AsyncData(
              JoinRequestSummary(
                pending: 1,
                approved: 1,
                rejected: 1,
              ),
            ),
          ),
          currentUserProfileProvider.overrideWith(
            (ref) => Stream.value(
              const AppUserProfile(
                id: SampleIds.currentUser,
                displayName: 'Owner',
                profilePhotoUrl: '',
                city: 'Istanbul',
                bio: 'Owner profile',
                profileCompletion: 80,
                favoriteActivities: [ActivityCategory.coffee],
                activeTimes: <AvailabilitySlot>[],
                groupPreference: GroupPreference.flexible,
                socialMood: SocialMood.calm,
                verificationLabel: 'phone',
                verificationLevel: VerificationLevel.phone,
              ),
            ),
          ),
          currentUserIdProvider.overrideWith((ref) => SampleIds.currentUser),
        ],
      );
      await tester.drag(find.byType(ListView).last, const Offset(0, -1800));
      await tester.pumpAndSettle();

      final pendingDy = tester.getTopLeft(find.text('Pending request')).dy;
      final approvedDy = tester.getTopLeft(find.text('Approved request')).dy;
      final cancelledDy = tester.getTopLeft(find.text('Cancelled request')).dy;

      expect(pendingDy, lessThan(approvedDy));
      expect(approvedDy, lessThan(cancelledDy));
      expect(find.textContaining('Owner coffee plan'), findsWidgets);
    },
  );
}
