import 'package:aktivite/app/app_routes.dart';
import 'package:aktivite/app/theme/app_breakpoints.dart';
import 'package:aktivite/core/constants/app_spacing.dart';
import 'package:aktivite/core/enums/activity_category.dart';
import 'package:aktivite/core/enums/discovery_distance_filter.dart';
import 'package:aktivite/core/enums/discovery_surface.dart';
import 'package:aktivite/core/utils/analytics_events.dart';
import 'package:aktivite/core/utils/localized_labels.dart';
import 'package:aktivite/core/utils/plan_matching.dart';
import 'package:aktivite/features/explore/application/explore_controller.dart';
import 'package:aktivite/features/monetization/domain/user_entitlement.dart';
import 'package:aktivite/features/profile/presentation/profile_screen.dart';
import 'package:aktivite/l10n/app_localizations.dart';
import 'package:aktivite/shared/models/activity_plan.dart';
import 'package:aktivite/shared/providers/app_providers.dart';
import 'package:aktivite/shared/providers/repository_providers.dart';
import 'package:aktivite/shared/widgets/activity_plan_card.dart';
import 'package:aktivite/shared/widgets/async_value_view.dart';
import 'package:aktivite/shared/widgets/app_page_scaffold.dart';
import 'package:aktivite/shared/widgets/app_section_header.dart';
import 'package:aktivite/shared/widgets/app_surface.dart';
import 'package:aktivite/shared/widgets/join_plan_action.dart';
import 'package:aktivite/shared/widgets/plan_match_reason_chips.dart';
import 'package:aktivite/shared/widgets/profile_gate_card.dart';
import 'package:aktivite/shared/widgets/route_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    final entitlement = ref.watch(currentUserEntitlementProvider).valueOrNull ??
        const UserEntitlement.free(userId: 'signed-out');
    final premiumEnabled = ref.watch(premiumEnabledProvider);

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

    return AppPageScaffold(
      title: l10n.exploreTitle,
      child: ListView(
        children: [
          AppSectionHeader(
            title: l10n.exploreTitle,
            subtitle: l10n.exploreSuggestedPlans,
          ),
          const SizedBox(height: AppSpacing.md),
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
            entitlement: entitlement,
            premiumEnabled: premiumEnabled,
          ),
          const SizedBox(height: AppSpacing.lg),
          ...filteredPlansAsync.when(
            data: (plans) {
              if (plans.isEmpty) {
                return [
                  AppSurface(
                    tonal: true,
                    child: Column(
                      children: [
                        AppSectionHeader(
                          title: l10n.exploreEmptyTitle,
                          subtitle: l10n.exploreEmptyMessage,
                          centered: true,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        RouteActionButton(
                          label: l10n.openPlansAction,
                          route: AppRoutes.activities,
                        ),
                      ],
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
    required this.entitlement,
    required this.premiumEnabled,
  });

  final List<(DiscoverySurface, String)> surfaces;
  final List<(ActivityCategory?, String)> categories;
  final ExploreState state;
  final UserEntitlement entitlement;
  final bool premiumEnabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(exploreControllerProvider.notifier);
    final distanceFilters = ref.watch(availableDistanceFiltersProvider);
    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: l10n.exploreFilterTitle,
            subtitle: l10n.exploreDistanceHint,
          ),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < AppBreakpoints.medium;
              final fields = <Widget>[
                _FilterField(
                  label: l10n.exploreDiscoverySections,
                  icon: Icons.explore_outlined,
                  child: DropdownButtonFormField<DiscoverySurface>(
                    initialValue: state.surface,
                    isDense: true,
                    isExpanded: true,
                    decoration: const InputDecoration(),
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
                _FilterField(
                  label: l10n.exploreCategoryFilters,
                  icon: Icons.category_outlined,
                  child: DropdownButtonFormField<ActivityCategory?>(
                    initialValue: state.category,
                    isDense: true,
                    isExpanded: true,
                    decoration: const InputDecoration(),
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
                _FilterField(
                  label: l10n.exploreDistanceFilters,
                  icon: Icons.near_me_outlined,
                  child: DropdownButtonFormField<DiscoveryDistanceFilter>(
                    initialValue: state.distanceFilter,
                    isDense: true,
                    isExpanded: true,
                    decoration: const InputDecoration(),
                    items: distanceFilters
                        .map(
                          (filter) => DropdownMenuItem<DiscoveryDistanceFilter>(
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
              ];

              if (stacked) {
                return Column(
                  children: [
                    for (var i = 0; i < fields.length; i++) ...[
                      fields[i],
                      if (i != fields.length - 1)
                        const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: fields[0]),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: fields[1]),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: fields[2]),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          if (premiumEnabled && entitlement.supportsAdvancedFilters) ...[
            Row(
              children: [
                Icon(
                  Icons.tune_outlined,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    l10n.premiumFilters,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                FilterChip(
                  label: Text(l10n.activityIndoor),
                  selected: state.indoorOnly,
                  onSelected: controller.setIndoorOnly,
                ),
                FilterChip(
                  label: Text(l10n.exploreOpenSpotsOnly),
                  selected: state.openSpotsOnly,
                  onSelected: controller.setOpenSpotsOnly,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
          ] else if (premiumEnabled) ...[
            AppSurface(
              tonal: true,
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  const Icon(Icons.workspace_premium_outlined),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(l10n.exploreAdvancedFiltersUpsell)),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.settings),
                    child: Text(l10n.openSettingsAction),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
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

class _FilterField extends StatelessWidget {
  const _FilterField({
    required this.label,
    required this.icon,
    required this.child,
  });

  final String label;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        child,
      ],
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
