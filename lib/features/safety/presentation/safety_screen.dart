import 'package:aktivite/app/app_routes.dart';
import 'package:aktivite/core/constants/app_spacing.dart';
import 'package:aktivite/core/utils/analytics_events.dart';
import 'package:aktivite/core/utils/app_feedback.dart';
import 'package:aktivite/core/utils/event_formatters.dart';
import 'package:aktivite/core/utils/trust_event_factory.dart';
import 'package:aktivite/features/auth/application/session_controller.dart';
import 'package:aktivite/l10n/app_localizations.dart';
import 'package:aktivite/shared/providers/app_providers.dart';
import 'package:aktivite/shared/providers/repository_providers.dart';
import 'package:aktivite/shared/widgets/app_section_card.dart';
import 'package:aktivite/shared/widgets/async_value_view.dart';
import 'package:aktivite/shared/widgets/trust_signal_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SafetyScreen extends ConsumerWidget {
  const SafetyScreen({super.key});

  static const routePath = AppRoutes.safety;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionControllerProvider);
    final trustSignals = ref.watch(trustSignalsProvider);
    final trustEventsAsync = ref.watch(currentUserModerationEventsProvider);
    final blockedUserIdsAsync = ref.watch(blockedUserIdsProvider);
    final safetySummaryAsync = ref.watch(safetyActionSummaryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.safetyTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          AppSectionCard(
            title: l10n.safetyCenterTitle,
            subtitle: l10n.safetyCenterSubtitle,
            child: TrustSignalList(
              signals: trustSignals,
              leading: const Icon(Icons.shield_outlined),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...safetySummaryAsync.when(
            data: (summary) => [
              AppSectionCard(
                title: l10n.safetySummaryTitle,
                subtitle: l10n.safetySummarySubtitle,
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    Chip(
                      label: Text(
                        l10n.safetyBlockedCount(summary.blockedCount),
                      ),
                    ),
                    Chip(
                      label: Text(
                        l10n.safetyReportedCount(summary.reportCount),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            loading: () => const <Widget>[],
            error: (error, stackTrace) => const <Widget>[],
          ),
          AppSectionCard(
            title: l10n.safetyTimelineTitle,
            subtitle: l10n.safetyTimelineSubtitle,
            child: trustEventsAsync.when(
              data: (events) {
                if (events.isEmpty) {
                  return Text(l10n.safetyTimelineEmpty);
                }
                return Column(
                  children: events
                      .map(
                        (event) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            event.isUserVisible
                                ? Icons.visibility_outlined
                                : Icons.lock_outline,
                          ),
                          title: Text(trustEventTitle(l10n, event)),
                          subtitle: Text(
                            '${trustEventSubtitle(l10n, event)} | ${formatTimeLabel(event.createdAt)}',
                          ),
                        ),
                      )
                      .toList(growable: false),
                );
              },
              loading: () => const AsyncLoadingView(),
              error: (error, stackTrace) =>
                  AsyncErrorView(message: error.toString()),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...blockedUserIdsAsync.when(
            data: (blockedUserIds) {
              if (blockedUserIds.isEmpty) {
                return const <Widget>[];
              }
              return [
                AppSectionCard(
                  title: l10n.safetyBlockedUsersTitle,
                  subtitle: l10n.safetyBlockedUsersSubtitle,
                  child: Column(
                    children: blockedUserIds
                        .map(
                          (userId) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.block_outlined),
                            title: Text(userId),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
              ];
            },
            loading: () => const <Widget>[],
            error: (error, stackTrace) => <Widget>[
              AsyncErrorView(message: error.toString()),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.tonalIcon(
            onPressed: safetySummaryAsync.valueOrNull?.hasReportedGuestUser ==
                    true
                ? null
                : () {
                    final userId = session.userId;
                    if (userId == null) {
                      return;
                    }
                    ref.read(moderationRepositoryProvider).createTrustEvent(
                          createReportSubmittedTrustEvent(
                            subjectUserId: userId,
                            reportedUserId: TrustEventReasonCodes.guestUserId,
                          ),
                        );
                    ref.read(analyticsServiceProvider).logEvent(
                          name: AnalyticsEvents.safetyReportSubmitted,
                        );
                    showAppSnackBar(context, l10n.safetyReportSubmittedToast);
                  },
            icon: const Icon(Icons.report_outlined),
            label: Text(
              safetySummaryAsync.valueOrNull?.hasReportedGuestUser == true
                  ? l10n.safetyReportAlreadySubmitted
                  : l10n.reportUser,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: safetySummaryAsync.valueOrNull?.hasBlockedGuestUser ==
                    true
                ? null
                : () {
                    final userId = session.userId;
                    if (userId == null) {
                      return;
                    }
                    ref.read(moderationRepositoryProvider).createTrustEvent(
                          createUserBlockedTrustEvent(
                            subjectUserId: userId,
                            blockedUserId: TrustEventReasonCodes.guestUserId,
                          ),
                        );
                    ref.read(analyticsServiceProvider).logEvent(
                          name: AnalyticsEvents.safetyUserBlocked,
                        );
                    showAppSnackBar(context, l10n.safetyUserBlockedToast);
                  },
            icon: const Icon(Icons.block_outlined),
            label: Text(
              safetySummaryAsync.valueOrNull?.hasBlockedGuestUser == true
                  ? l10n.safetyUserAlreadyBlocked
                  : l10n.blockUser,
            ),
          ),
        ],
      ),
    );
  }
}
