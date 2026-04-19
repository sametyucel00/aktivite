import 'package:aktivite/app/app_routes.dart';
import 'package:aktivite/core/constants/app_spacing.dart';
import 'package:aktivite/core/enums/activity_category.dart';
import 'package:aktivite/core/enums/discovery_surface.dart';
import 'package:aktivite/core/utils/analytics_events.dart';
import 'package:aktivite/core/utils/plan_matching.dart';
import 'package:aktivite/features/explore/application/explore_controller.dart';
import 'package:aktivite/features/profile/presentation/profile_screen.dart';
import 'package:aktivite/l10n/app_localizations.dart';
import 'package:aktivite/shared/models/activity_plan.dart';
import 'package:aktivite/shared/providers/app_providers.dart';
import 'package:aktivite/shared/providers/repository_providers.dart';
import 'package:aktivite/shared/widgets/activity_plan_card.dart';
import 'package:aktivite/shared/widgets/app_section_card.dart';
import 'package:aktivite/shared/widgets/async_value_view.dart';
import 'package:aktivite/shared/widgets/join_plan_action.dart';
import 'package:aktivite/shared/widgets/plan_match_reason_chips.dart';
import 'package:aktivite/shared/widgets/profile_gate_card.dart';
import 'package:aktivite/shared/widgets/route_action_button.dart';
import 'package:aktivite/shared/widgets/trust_signal_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  static const routePath = AppRoutes.explore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final exploreState = ref.watch(exploreControllerProvider);
    final filteredPlansAsync = ref.watch(filteredPlansProvider);
    final canCreatePlansAsync = ref.watch(canCreatePlansProvider);
    final completionAsync = ref.watch(profileCompletionProvider);
    final trustSignals = ref.watch(trustSignalsProvider);

    final surfaces = <(DiscoverySurface, String)>[
      (DiscoverySurface.now, l10n.surfaceNow),
      (DiscoverySurface.tonight, l10n.surfaceTonight),
      (DiscoverySurface.nearby, l10n.surfaceNearby),
      (DiscoverySurface.weekend, l10n.surfaceWeekend),
      (DiscoverySurface.groups, l10n.surfaceGroups),
    ];
    final categories = <(ActivityCategory?, String)>[
      (null, l10n.exploreCategoryAll),
      (ActivityCategory.coffee, l10n.activityCoffee),
      (ActivityCategory.walk, l10n.activityWalk),
      (ActivityCategory.chat, l10n.activityChat),
      (ActivityCategory.cowork, l10n.activityCowork),
      (ActivityCategory.event, l10n.activityEvent),
      (ActivityCategory.movie, l10n.activityMovie),
      (ActivityCategory.games, l10n.activityGames),
      (ActivityCategory.sports, l10n.activitySports),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.exploreTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          ...switch ((
            completionAsync.valueOrNull,
            canCreatePlansAsync.valueOrNull
          )) {
            (final int completion, false) => [
                ProfileGateCard(
                  completion: completion,
                  profileRoute: ProfileScreen.routePath,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            (_, _) when completionAsync.hasError => <Widget>[
                AsyncErrorView(message: completionAsync.error.toString()),
                const SizedBox(height: AppSpacing.md),
              ],
            _ => const <Widget>[],
          },
          AppSectionCard(
            title: l10n.exploreDiscoverySections,
            subtitle: l10n.exploreDiscoveryHint,
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: surfaces
                  .map(
                    (surface) => FilterChip(
                      selected: exploreState.surface == surface.$1,
                      label: Text(surface.$2),
                      onSelected: (_) {
                        ref
                            .read(exploreControllerProvider.notifier)
                            .setSurface(surface.$1);
                        ref.read(analyticsServiceProvider).logEvent(
                          name: AnalyticsEvents.exploreSurfaceSelected,
                          parameters: {
                            'surface': surface.$1.name,
                          },
                        );
                      },
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppSectionCard(
            title: l10n.exploreCategoryFilters,
            subtitle: l10n.exploreCategoryHint,
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: categories
                  .map(
                    (category) => FilterChip(
                      selected: exploreState.category == category.$1,
                      label: Text(category.$2),
                      onSelected: (_) {
                        ref
                            .read(exploreControllerProvider.notifier)
                            .setCategory(category.$1);
                        ref.read(analyticsServiceProvider).logEvent(
                          name: AnalyticsEvents.exploreCategorySelected,
                          parameters: {
                            'category': category.$1?.name ?? 'all',
                          },
                        );
                      },
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.exploreSuggestedPlans,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          ...filteredPlansAsync.when(
            data: (plans) {
              if (plans.isEmpty) {
                return [
                  AppSectionCard(
                    title: l10n.exploreEmptyTitle,
                    subtitle: l10n.exploreEmptyMessage,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: RouteActionButton(
                        label: l10n.openPlansAction,
                        route: AppRoutes.activities,
                      ),
                    ),
                  ),
                ];
              }
              return plans
                  .map(
                    (plan) => _ExplorePlanCard(
                      plan: plan,
                      selectedSurface: exploreState.surface,
                    ),
                  )
                  .toList(growable: false);
            },
            loading: () => const [AsyncLoadingView()],
            error: (error, stackTrace) =>
                [AsyncErrorView(message: error.toString())],
          ),
          const SizedBox(height: AppSpacing.md),
          AppSectionCard(
            title: l10n.safetyTitle,
            subtitle: l10n.exploreSafetyHint,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TrustSignalList(signals: trustSignals),
                Align(
                  alignment: Alignment.centerLeft,
                  child: RouteActionButton(
                    label: l10n.openSafetyCenterAction,
                    route: AppRoutes.safety,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExplorePlanCard extends ConsumerWidget {
  const _ExplorePlanCard({
    required this.plan,
    required this.selectedSurface,
  });

  final ActivityPlan plan;
  final DiscoverySurface selectedSurface;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profile = ref.watch(currentUserProfileProvider).valueOrNull;

    return ActivityPlanCard(
      plan: plan,
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (profile != null &&
              planMatchReasons(profile, plan).isNotEmpty) ...[
            Text(
              l10n.exploreSuggestedReasonTitle,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            PlanMatchReasonChips(
              reasons: planMatchReasons(profile, plan),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          Align(
            alignment: Alignment.centerLeft,
            child: JoinPlanAction(
              plan: plan,
              analyticsEventName: AnalyticsEvents.joinRequestSubmitted,
              analyticsParameters: {
                'surface': selectedSurface.name,
              },
            ),
          ),
        ],
      ),
    );
  }
}
