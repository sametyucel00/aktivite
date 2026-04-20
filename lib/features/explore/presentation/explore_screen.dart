import 'package:aktivite/app/app_routes.dart';
import 'package:aktivite/core/constants/app_spacing.dart';
import 'package:aktivite/core/enums/activity_category.dart';
import 'package:aktivite/core/enums/discovery_distance_filter.dart';
import 'package:aktivite/core/enums/discovery_surface.dart';
import 'package:aktivite/core/utils/analytics_events.dart';
import 'package:aktivite/core/utils/localized_labels.dart';
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
          _ExploreFilterPanel(
            surfaces: surfaces,
            categories: categories,
            state: exploreState,
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
        ],
      ),
    );
  }
}

class _ExploreFilterPanel extends ConsumerWidget {
  const _ExploreFilterPanel({
    required this.surfaces,
    required this.categories,
    required this.state,
  });

  final List<(DiscoverySurface, String)> surfaces;
  final List<(ActivityCategory?, String)> categories;
  final ExploreState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(exploreControllerProvider.notifier);
    return AppSectionCard(
      title: l10n.exploreFilterTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final fieldWidth =
                  (constraints.maxWidth - (AppSpacing.sm * 2)) / 3;
              return Row(
                children: [
                  SizedBox(
                    width: fieldWidth,
                    child: DropdownButtonFormField<DiscoverySurface>(
                      initialValue: state.surface,
                      isDense: true,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: l10n.exploreDiscoverySections,
                        prefixIcon: const Icon(Icons.explore_outlined),
                      ),
                      items: surfaces
                          .map(
                            (surface) => DropdownMenuItem(
                              value: surface.$1,
                              child: Text(
                                surface.$2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (surface) {
                        if (surface == null) {
                          return;
                        }
                        controller.setSurface(surface);
                        ref.read(analyticsServiceProvider).logEvent(
                          name: AnalyticsEvents.exploreSurfaceSelected,
                          parameters: {'surface': surface.name},
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: fieldWidth,
                    child: DropdownButtonFormField<ActivityCategory?>(
                      initialValue: state.category,
                      isDense: true,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: l10n.exploreCategoryFilters,
                        prefixIcon: const Icon(Icons.category_outlined),
                      ),
                      items: categories
                          .map(
                            (category) => DropdownMenuItem<ActivityCategory?>(
                              value: category.$1,
                              child: Text(
                                category.$2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (category) {
                        controller.setCategory(category);
                        ref.read(analyticsServiceProvider).logEvent(
                          name: AnalyticsEvents.exploreCategorySelected,
                          parameters: {'category': category?.name ?? 'all'},
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: fieldWidth,
                    child: DropdownButtonFormField<DiscoveryDistanceFilter>(
                      initialValue: state.distanceFilter,
                      isDense: true,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: l10n.exploreDistanceFilters,
                        prefixIcon: const Icon(Icons.near_me_outlined),
                      ),
                      items: DiscoveryDistanceFilter.values
                          .map(
                            (filter) => DropdownMenuItem(
                              value: filter,
                              child: Text(
                                discoveryDistanceFilterLabel(l10n, filter),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (filter) {
                        if (filter != null) {
                          controller.setDistanceFilter(filter);
                        }
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.exploreDistanceHint,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            onPressed: controller.resetFilters,
            icon: const Icon(Icons.refresh_outlined),
            label: Text(l10n.exploreClearFilters),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome_outlined, size: 18),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  l10n.exploreSuggestedReasonTitle,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            PlanMatchReasonChips(
              reasons: planMatchReasons(profile, plan),
              maxItems: 2,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          Align(
            alignment: Alignment.center,
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
