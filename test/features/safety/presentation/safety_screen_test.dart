import 'package:aktivite/core/config/sample_ids.dart';
import 'package:aktivite/core/utils/trust_event_factory.dart';
import 'package:aktivite/features/safety/presentation/safety_screen.dart';
import 'package:aktivite/shared/models/moderation_event.dart';
import 'package:aktivite/shared/models/safety_action_summary.dart';
import 'package:aktivite/shared/providers/app_providers.dart';
import 'package:aktivite/shared/providers/repository_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test_helpers/fakes.dart';
import '../../../test_helpers/test_harness.dart';

void main() {
  testWidgets(
    'shows controlled report reasons and private safety summaries',
    (tester) async {
      final safetyRepository = FakeSafetyRepository();
      final moderationRepository = FakeModerationRepository(
        initialEvents: [
          ModerationEvent(
            id: 'visible-1',
            subjectUserId: SampleIds.currentUser,
            reasonCode: TrustEventReasonCodes.safeMeetupReminderEnabled,
            isUserVisible: true,
            createdAt: DateTime(2026, 4, 19, 12),
          ),
          ModerationEvent(
            id: 'internal-1',
            subjectUserId: SampleIds.currentUser,
            reasonCode: TrustEventReasonCodes.phoneVerified,
            isUserVisible: false,
            createdAt: DateTime(2026, 4, 18, 12),
          ),
        ],
      );

      await pumpTestApp(
        tester,
        child: const SafetyScreen(),
        overrides: [
          safetyRepositoryProvider.overrideWithValue(safetyRepository),
          moderationRepositoryProvider.overrideWithValue(moderationRepository),
          currentUserModerationEventsProvider.overrideWith(
            (ref) =>
                moderationRepository.watchTrustEvents(SampleIds.currentUser),
          ),
          blockedUserIdsProvider.overrideWith(
            (ref) => const AsyncValue.data({'guest-1'}),
          ),
          reportedReasonsByUserProvider.overrideWith(
            (ref) => const AsyncValue.data(<String, List<String>>{}),
          ),
          safetyTargetUserIdsProvider.overrideWith(
            (ref) => const AsyncValue.data(['guest-1']),
          ),
          safetyActionSummaryProvider.overrideWith(
            (ref) => const AsyncValue.data(
              SafetyActionSummary(
                blockedCount: 1,
                reportCount: 2,
              ),
            ),
          ),
          analyticsServiceProvider.overrideWithValue(FakeAnalyticsService()),
        ],
      );

      expect(find.text('Private reports'), findsOneWidget);
      expect(find.byType(Chip), findsWidgets);

      await tester.scrollUntilVisible(find.text('Report user'), 300);
      await tester.tap(find.text('Report user'));
      await tester.pumpAndSettle();

      expect(find.text('Why are you reporting this user?'), findsOneWidget);
      await tester.tap(find.text('Harassment'));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Report user').last);
      await tester.pumpAndSettle();

      expect(safetyRepository.lastReportReason, 'harassment');
      expect(find.text('Report submitted.'), findsOneWidget);
    },
  );
}
