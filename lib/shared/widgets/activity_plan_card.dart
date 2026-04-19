import 'package:aktivite/core/constants/app_spacing.dart';
import 'package:aktivite/core/enums/activity_status.dart';
import 'package:aktivite/l10n/app_localizations.dart';
import 'package:aktivite/shared/design_system/app_badge.dart';
import 'package:aktivite/shared/models/activity_plan.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ActivityPlanCard extends StatelessWidget {
  const ActivityPlanCard({
    required this.plan,
    this.footer,
    super.key,
  });

  final ActivityPlan plan;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typography = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                AppBadge(label: plan.timeLabel),
                AppBadge(label: plan.city),
                AppBadge(label: plan.approximateLocation),
                AppBadge(label: _statusLabel(l10n, plan.status)),
                AppBadge(
                  label: plan.isIndoor
                      ? l10n.activityIndoor
                      : l10n.activityOutdoor,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(plan.title, style: typography.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(plan.description, style: typography.bodyMedium),
            const SizedBox(height: AppSpacing.md),
            Text(
              '${DateFormat('dd MMM, HH:mm').format(plan.scheduledAt)} - ${l10n.activityDurationMinutes(plan.durationMinutes)}',
              style: typography.bodySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.peopleCount(plan.participantCount, plan.maxParticipants),
              style: typography.labelLarge,
            ),
            if (footer != null) ...[
              const SizedBox(height: AppSpacing.md),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}

String _statusLabel(AppLocalizations l10n, ActivityStatus status) {
  switch (status) {
    case ActivityStatus.draft:
      return l10n.activityStatusDraft;
    case ActivityStatus.open:
      return l10n.activityStatusOpen;
    case ActivityStatus.full:
      return l10n.activityStatusFull;
    case ActivityStatus.completed:
      return l10n.activityStatusCompleted;
    case ActivityStatus.cancelled:
      return l10n.activityStatusCancelled;
  }
}
