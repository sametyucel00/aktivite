import 'package:aktivite/core/constants/app_spacing.dart';
import 'package:aktivite/core/enums/plan_match_reason.dart';
import 'package:aktivite/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class PlanMatchReasonChips extends StatelessWidget {
  const PlanMatchReasonChips({
    required this.reasons,
    this.maxItems,
    super.key,
  });

  final List<PlanMatchReason> reasons;
  final int? maxItems;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final visibleReasons = maxItems == null
        ? reasons
        : reasons.take(maxItems!).toList(growable: false);

    if (visibleReasons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: visibleReasons
          .map(
            (reason) => Chip(
              label: Text(_labelForReason(l10n, reason)),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          )
          .toList(growable: false),
    );
  }
}

String _labelForReason(
  AppLocalizations l10n,
  PlanMatchReason reason,
) {
  switch (reason) {
    case PlanMatchReason.favoriteActivity:
      return l10n.exploreReasonActivityMatch;
    case PlanMatchReason.activeTime:
      return l10n.exploreReasonTimeMatch;
    case PlanMatchReason.groupPreference:
      return l10n.exploreReasonGroupMatch;
    case PlanMatchReason.openNow:
      return l10n.exploreReasonOpenNow;
  }
}
