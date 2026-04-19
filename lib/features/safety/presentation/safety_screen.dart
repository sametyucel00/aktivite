import 'package:aktivite/app/app_routes.dart';
import 'package:aktivite/core/constants/safety_report_reasons.dart';
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

  static const _reportReasonOptions = <String>[
    SafetyReportReasons.unsafeMeetup,
    SafetyReportReasons.harassment,
    SafetyReportReasons.spam,
    SafetyReportReasons.fakeProfile,
    SafetyReportReasons.inappropriateContent,
  ];

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
                    if (summary.reportCount > 0)
                      Chip(
                        label: Text(l10n.safetyReportsPrivateLabel),
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
                          trailing: Chip(
                            label: Text(
                              event.isUserVisible
                                  ? l10n.safetyEventVisible
                                  : l10n.safetyEventInternal,
                            ),
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
                            title: Text(_safetyUserLabel(l10n, userId)),
                            subtitle: Text(userId),
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
          AppSectionCard(
            title: l10n.safetyReportsTitle,
            subtitle: l10n.safetyReportsPrivateSummary,
            child: Text(
              l10n.safetyReportsPrivateHint(
                safetySummaryAsync.valueOrNull?.reportCount ?? 0,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.tonalIcon(
            onPressed: safetySummaryAsync.valueOrNull?.hasReportedGuestUser ==
                    true
                ? null
                : () async {
                    final userId = session.userId;
                    if (userId == null) {
                      showAppSnackBar(
                        context,
                        l10n.safetyActionUnavailableToast,
                      );
                      return;
                    }
                    final reason = await _showReportReasonDialog(context, l10n);
                    if (reason == null) {
                      return;
                    }
                    try {
                      await ref.read(safetyRepositoryProvider).reportUser(
                            targetUserId: TrustEventReasonCodes.guestUserId,
                            reason: reason,
                          );
                      await ref
                          .read(moderationRepositoryProvider)
                          .createTrustEvent(
                            createReportSubmittedTrustEvent(
                              subjectUserId: userId,
                              reportedUserId: TrustEventReasonCodes.guestUserId,
                            ),
                          );
                      await ref.read(analyticsServiceProvider).logEvent(
                            name: AnalyticsEvents.safetyReportSubmitted,
                          );
                      if (!context.mounted) {
                        return;
                      }
                      showAppSnackBar(
                        context,
                        l10n.safetyReportSubmittedToast,
                      );
                    } catch (_) {
                      if (!context.mounted) {
                        return;
                      }
                      showAppSnackBar(context, l10n.safetyActionFailedToast);
                    }
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
                      showAppSnackBar(
                        context,
                        l10n.safetyActionUnavailableToast,
                      );
                      return;
                    }
                    () async {
                      try {
                        await ref.read(safetyRepositoryProvider).blockUser(
                              targetUserId: TrustEventReasonCodes.guestUserId,
                            );
                        await ref
                            .read(moderationRepositoryProvider)
                            .createTrustEvent(
                              createUserBlockedTrustEvent(
                                subjectUserId: userId,
                                blockedUserId:
                                    TrustEventReasonCodes.guestUserId,
                              ),
                            );
                        await ref.read(analyticsServiceProvider).logEvent(
                              name: AnalyticsEvents.safetyUserBlocked,
                            );
                        if (!context.mounted) {
                          return;
                        }
                        showAppSnackBar(context, l10n.safetyUserBlockedToast);
                      } catch (_) {
                        if (!context.mounted) {
                          return;
                        }
                        showAppSnackBar(context, l10n.safetyActionFailedToast);
                      }
                    }();
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

  Future<String?> _showReportReasonDialog(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    String? selectedReason = _reportReasonOptions.first;

    return showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(l10n.safetyReportReasonDialogTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.safetyReportReasonDialogHint),
                const SizedBox(height: AppSpacing.md),
                RadioGroup<String>(
                  groupValue: selectedReason,
                  onChanged: (value) {
                    setState(() {
                      selectedReason = value;
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _reportReasonOptions
                        .map(
                          (reason) => RadioListTile<String>(
                            value: reason,
                            contentPadding: EdgeInsets.zero,
                            title: Text(_reportReasonLabel(l10n, reason)),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.commonCancel),
              ),
              FilledButton(
                onPressed: selectedReason == null
                    ? null
                    : () => Navigator.of(context).pop(selectedReason),
                child: Text(l10n.reportUser),
              ),
            ],
          ),
        );
      },
    );
  }

  String _reportReasonLabel(AppLocalizations l10n, String reason) {
    switch (reason) {
      case SafetyReportReasons.spam:
        return l10n.safetyReportReasonSpam;
      case SafetyReportReasons.harassment:
        return l10n.safetyReportReasonHarassment;
      case SafetyReportReasons.unsafeMeetup:
        return l10n.safetyReportReasonUnsafeMeetup;
      case SafetyReportReasons.fakeProfile:
        return l10n.safetyReportReasonFakeProfile;
      case SafetyReportReasons.inappropriateContent:
        return l10n.safetyReportReasonInappropriateContent;
    }
    return reason;
  }

  String _safetyUserLabel(AppLocalizations l10n, String userId) {
    if (userId == TrustEventReasonCodes.guestUserId) {
      return l10n.guestPreviewLabel;
    }
    final compactId = userId.length <= 10 ? userId : userId.substring(0, 10);
    return l10n.memberLabel(compactId);
  }
}
