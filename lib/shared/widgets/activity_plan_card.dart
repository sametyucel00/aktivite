import 'package:aktivite/app/theme/app_radii.dart';
import 'package:aktivite/core/constants/app_spacing.dart';
import 'package:aktivite/core/enums/activity_status.dart';
import 'package:aktivite/core/utils/localized_labels.dart';
import 'package:aktivite/l10n/app_localizations.dart';
import 'package:aktivite/shared/design_system/app_badge.dart';
import 'package:aktivite/shared/models/activity_plan.dart';
import 'package:aktivite/shared/widgets/app_surface.dart';
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
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppSurface(
        padding: EdgeInsets.all(
          MediaQuery.sizeOf(context).width < 420
              ? AppSpacing.md
              : AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Icon(
                    activityIcon(plan.category),
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(plan.title, style: typography.titleMedium),
                          AppBadge(label: _statusLabel(l10n, plan.status)),
                          if (plan.hasActiveBoostAt(DateTime.now()))
                            AppBadge(label: l10n.boostedBadge),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        activityLabel(l10n, plan.category),
                        style: typography.labelLarge?.copyWith(
                          color: scheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              plan.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: typography.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _MetaPill(
                  icon: Icons.schedule_outlined,
                  label: DateFormat('dd MMM, HH:mm').format(plan.scheduledAt),
                ),
                _MetaPill(
                  icon: Icons.timer_outlined,
                  label: l10n.activityDurationMinutes(plan.durationMinutes),
                ),
                _MetaPill(
                  icon: Icons.groups_2_outlined,
                  label: l10n.peopleCount(
                    plan.participantCount,
                    plan.maxParticipants,
                  ),
                ),
                _MetaPill(
                  icon: Icons.place_outlined,
                  label: '${plan.city} / ${plan.approximateLocation}',
                ),
                _MetaPill(
                  icon: plan.isIndoor
                      ? Icons.meeting_room_outlined
                      : Icons.park_outlined,
                  label: plan.isIndoor
                      ? l10n.activityIndoor
                      : l10n.activityOutdoor,
                ),
                _MetaPill(
                  icon: Icons.near_me_outlined,
                  label: plan.distanceKm == null
                      ? l10n.activityDistanceUnknown
                      : l10n.activityDistanceKm(plan.distanceKm!),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Row(
                children: [
                  Icon(Icons.person_outline, size: 18, color: scheme.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      l10n.planOwnerLabel(_compactMemberId(plan.ownerUserId)),
                      overflow: TextOverflow.ellipsis,
                      style: typography.bodySmall,
                    ),
                  ),
                ],
              ),
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

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: IntrinsicWidth(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: scheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _compactMemberId(String userId) {
  final trimmed = userId.trim();
  if (trimmed.length <= 10) {
    return trimmed;
  }
  return trimmed.substring(0, 10);
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
