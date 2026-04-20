import 'package:aktivite/app/app_routes.dart';
import 'package:aktivite/core/constants/app_spacing.dart';
import 'package:aktivite/core/enums/map_privacy_mode.dart';
import 'package:aktivite/core/utils/analytics_events.dart';
import 'package:aktivite/core/utils/localized_labels.dart';
import 'package:aktivite/core/utils/plan_matching.dart';
import 'package:aktivite/l10n/app_localizations.dart';
import 'package:aktivite/shared/models/activity_plan.dart';
import 'package:aktivite/shared/models/app_user_profile.dart';
import 'package:aktivite/shared/providers/app_providers.dart';
import 'package:aktivite/shared/widgets/app_section_card.dart';
import 'package:aktivite/shared/widgets/async_value_view.dart';
import 'package:aktivite/shared/widgets/join_plan_action.dart';
import 'package:aktivite/shared/widgets/plan_match_reason_chips.dart';
import 'package:aktivite/shared/widgets/route_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  static const routePath = AppRoutes.map;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final privacyMode = ref.watch(effectiveMapPrivacyProvider);
    final recommendedPlansAsync = ref.watch(recommendedPlansProvider);
    final profile = ref.watch(currentUserProfileProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.mapTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          AppSectionCard(
            title: l10n.mapPrivacyTitle,
            subtitle:
                '${l10n.mapPrivacyMessage} ${mapPrivacyModeLabel(l10n, privacyMode)}',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: MediaQuery.sizeOf(context).width < 420 ? 220 : 280,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                        Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withValues(alpha: 0.42),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _ApproximateMapPainter(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withValues(alpha: 0.12),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surface
                                    .withValues(alpha: 0.82),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                child: Text(l10n.mapPlaceholder),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Positioned(
                        top: 48,
                        left: 48,
                        child: _ApproximateArea(size: 84),
                      ),
                      const Positioned(
                        top: 120,
                        right: 52,
                        child: _ApproximateArea(size: 70),
                      ),
                      const Positioned(
                        bottom: 36,
                        left: 120,
                        child: _ApproximateArea(size: 64),
                      ),
                      if (privacyMode == MapPrivacyMode.hidden)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surface
                                  .withValues(alpha: 0.82),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              child: Text(
                                l10n.mapPrivacyHidden,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.mapRecommendedTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: RouteActionButton(
                    label: l10n.openSettingsAction,
                    route: AppRoutes.settings,
                    tonal: false,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                recommendedPlansAsync.when(
                  data: (plans) {
                    if (plans.isEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.mapRecommendedEmpty),
                          const SizedBox(height: AppSpacing.sm),
                          RouteActionButton(
                            label: l10n.openExploreAction,
                            route: AppRoutes.explore,
                          ),
                        ],
                      );
                    }
                    return Column(
                      children: plans
                          .take(3)
                          .map(
                            (plan) => _RecommendedPlanTile(
                              plan: plan,
                              privacyMode: privacyMode,
                              profile: profile,
                            ),
                          )
                          .toList(growable: false),
                    );
                  },
                  loading: () => const AsyncLoadingView(),
                  error: (error, stackTrace) =>
                      AsyncErrorView(message: error.toString()),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.mapNearbyPlansTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                recommendedPlansAsync.when(
                  data: (plans) {
                    if (plans.isEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.mapRecommendedEmpty),
                          const SizedBox(height: AppSpacing.sm),
                          RouteActionButton(
                            label: l10n.openExploreAction,
                            route: AppRoutes.explore,
                          ),
                        ],
                      );
                    }
                    final nearbyPlans =
                        plans.length <= 3 ? plans : plans.skip(3);
                    return Column(
                      children: nearbyPlans
                          .map(
                            (plan) => _NearbyPlanTile(
                              plan: plan,
                              privacyMode: privacyMode,
                            ),
                          )
                          .toList(growable: false),
                    );
                  },
                  loading: () => const AsyncLoadingView(),
                  error: (error, stackTrace) =>
                      AsyncErrorView(message: error.toString()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ApproximateMapPainter extends CustomPainter {
  const _ApproximateMapPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;
    for (var i = 1; i < 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 24), paint);
    }
    for (var i = 1; i < 4; i++) {
      final x = size.width * i / 4;
      canvas.drawLine(Offset(x, 0), Offset(x - 32, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ApproximateMapPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _RecommendedPlanTile extends ConsumerWidget {
  const _RecommendedPlanTile({
    required this.plan,
    required this.privacyMode,
    required this.profile,
  });

  final ActivityPlan plan;
  final MapPrivacyMode privacyMode;
  final AppUserProfile? profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(plan.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${plan.city} - ${mapPrivacyModeLabel(l10n, privacyMode)}'),
          const SizedBox(height: AppSpacing.xs),
          if (profile != null)
            PlanMatchReasonChips(
              reasons: planMatchReasons(profile!, plan),
              maxItems: 2,
            ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: JoinPlanAction(
              plan: plan,
              analyticsEventName: AnalyticsEvents.mapJoinRequestSubmitted,
              style: JoinPlanActionStyle.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _ApproximateArea extends StatelessWidget {
  const _ApproximateArea({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

class _NearbyPlanTile extends ConsumerWidget {
  const _NearbyPlanTile({
    required this.plan,
    required this.privacyMode,
  });

  final ActivityPlan plan;
  final MapPrivacyMode privacyMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(plan.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${plan.city} - ${mapPrivacyModeLabel(l10n, privacyMode)}'),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: JoinPlanAction(
              plan: plan,
              analyticsEventName: AnalyticsEvents.mapNearbyJoinRequestSubmitted,
              style: JoinPlanActionStyle.text,
            ),
          ),
        ],
      ),
    );
  }
}
