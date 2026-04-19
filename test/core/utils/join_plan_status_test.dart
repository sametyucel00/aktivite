import 'package:aktivite/core/enums/activity_category.dart';
import 'package:aktivite/core/enums/activity_status.dart';
import 'package:aktivite/core/enums/discovery_surface.dart';
import 'package:aktivite/core/enums/join_request_status.dart';
import 'package:aktivite/core/enums/plan_time_option.dart';
import 'package:aktivite/core/utils/join_plan_status.dart';
import 'package:aktivite/l10n/app_localizations_en.dart';
import 'package:aktivite/shared/models/activity_plan.dart';
import 'package:aktivite/shared/models/join_request.dart';
import 'package:flutter_test/flutter_test.dart';

final _englishL10n = AppLocalizationsEn();

void main() {
  group('joinPlanStatusLabel', () {
    test('returns awaiting approval for pending request', () {
      final label = joinPlanStatusLabel(
        l10n: _englishL10n,
        requests: const [
          JoinRequest(
            id: 'join-1',
            activityId: 'activity-1',
            requesterId: 'user-1',
            message: 'Can join now',
            status: JoinRequestStatus.pending,
          ),
        ],
        userId: 'user-1',
        plan: _plan(),
      );

      expect(label, _englishL10n.joinRequestAwaitingApproval);
    });

    test('returns own-plan notice for owner', () {
      final label = joinPlanStatusLabel(
        l10n: _englishL10n,
        requests: const [],
        userId: 'owner-1',
        plan: _plan(ownerUserId: 'owner-1'),
      );

      expect(label, _englishL10n.joinOwnPlanNotice);
    });

    test('returns full notice when capacity is reached', () {
      final label = joinPlanStatusLabel(
        l10n: _englishL10n,
        requests: const [],
        userId: 'guest-1',
        plan: _plan(participantCount: 4, maxParticipants: 4),
      );

      expect(label, _englishL10n.joinPlanFullNotice);
    });

    test('returns empty string when user can still request', () {
      final label = joinPlanStatusLabel(
        l10n: _englishL10n,
        requests: const [],
        userId: 'guest-1',
        plan: _plan(),
      );

      expect(label, isEmpty);
    });
  });

  group('canSubmitJoinRequest', () {
    test('blocks submission without profile capability', () {
      expect(
        canSubmitJoinRequest(
          plan: _plan(),
          requests: const [],
          userId: 'guest-1',
          canCreatePlans: false,
        ),
        isFalse,
      );
    });

    test('blocks submission when request already exists', () {
      expect(
        canSubmitJoinRequest(
          plan: _plan(),
          requests: const [
            JoinRequest(
              id: 'join-1',
              activityId: 'activity-1',
              requesterId: 'guest-1',
              message: 'Joining',
              status: JoinRequestStatus.approved,
            ),
          ],
          userId: 'guest-1',
          canCreatePlans: true,
        ),
        isFalse,
      );
    });

    test('allows submission for eligible user and open plan', () {
      expect(
        canSubmitJoinRequest(
          plan: _plan(),
          requests: const [],
          userId: 'guest-1',
          canCreatePlans: true,
        ),
        isTrue,
      );
    });
  });
}

ActivityPlan _plan({
  String ownerUserId = 'owner-1',
  int participantCount = 1,
  int maxParticipants = 4,
}) {
  return ActivityPlan(
    id: 'activity-1',
    ownerUserId: ownerUserId,
    title: 'Coffee tonight',
    description: 'Simple catch-up',
    category: ActivityCategory.coffee,
    city: 'Istanbul',
    approximateLocation: 'Kadikoy center',
    timeLabel: 'Tonight',
    timeOption: PlanTimeOption.tonight,
    scheduledAt: DateTime(2026, 4, 19, 19, 0),
    durationMinutes: 60,
    participantCount: participantCount,
    maxParticipants: maxParticipants,
    isIndoor: true,
    status: ActivityStatus.open,
    surfaces: const [
      DiscoverySurface.tonight,
      DiscoverySurface.nearby,
    ],
  );
}
