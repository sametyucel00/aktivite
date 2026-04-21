import 'package:aktivite/app/app_routes.dart';
import 'package:aktivite/core/constants/app_spacing.dart';
import 'package:aktivite/core/enums/map_privacy_mode.dart';
import 'package:aktivite/core/services/location_service.dart';
import 'package:aktivite/core/utils/analytics_events.dart';
import 'package:aktivite/core/utils/approximate_map_projection.dart';
import 'package:aktivite/core/utils/localized_labels.dart';
import 'package:aktivite/core/utils/plan_matching.dart';
import 'package:aktivite/l10n/app_localizations.dart';
import 'package:aktivite/shared/models/activity_plan.dart';
import 'package:aktivite/shared/models/app_user_profile.dart';
import 'package:aktivite/shared/providers/app_providers.dart';
import 'package:aktivite/shared/providers/repository_providers.dart';
import 'package:aktivite/shared/widgets/app_page_scaffold.dart';
import 'package:aktivite/shared/widgets/app_section_card.dart';
import 'package:aktivite/shared/widgets/app_section_header.dart';
import 'package:aktivite/shared/widgets/async_value_view.dart';
import 'package:aktivite/shared/widgets/join_plan_action.dart';
import 'package:aktivite/shared/widgets/plan_match_reason_chips.dart';
import 'package:aktivite/shared/widgets/route_action_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  static const routePath = AppRoutes.map;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final privacyMode = ref.watch(effectiveMapPrivacyProvider);
    final recommendedPlansAsync = ref.watch(recommendedPlansProvider);
    final currentLocationAsync = ref.watch(currentDeviceLocationProvider);
    final profile = ref.watch(currentUserProfileProvider).valueOrNull;
    final supportsInteractiveMap = kIsWeb ||
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;

    return AppPageScaffold(
      title: l10n.mapTitle,
      child: ListView(
        children: [
          AppSectionHeader(
            title: l10n.mapTitle,
            subtitle: l10n.mapPrivacyMessage,
          ),
          const SizedBox(height: AppSpacing.md),
          AppSectionCard(
            title: l10n.mapPrivacyTitle,
            subtitle:
                '${l10n.mapPrivacyMessage} ${mapPrivacyModeLabel(l10n, privacyMode)}',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MapPanel(
                  privacyMode: privacyMode,
                  recommendedPlansAsync: recommendedPlansAsync,
                  currentLocationAsync: currentLocationAsync,
                  supportsInteractiveMap: supportsInteractiveMap,
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

class _MapPanel extends ConsumerWidget {
  const _MapPanel({
    required this.privacyMode,
    required this.recommendedPlansAsync,
    required this.currentLocationAsync,
    required this.supportsInteractiveMap,
  });

  final MapPrivacyMode privacyMode;
  final AsyncValue<List<ActivityPlan>> recommendedPlansAsync;
  final AsyncValue<DeviceLocation?> currentLocationAsync;
  final bool supportsInteractiveMap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    if (privacyMode == MapPrivacyMode.hidden) {
      return _MapFallbackState(
        icon: Icons.lock_outline,
        title: l10n.mapPrivacyTitle,
        message: l10n.mapPrivacyHidden,
        actionLabel: l10n.openSettingsAction,
        onPressed: () => context.go(AppRoutes.settings),
      );
    }

    if (!supportsInteractiveMap) {
      return _MapFallbackState(
        icon: Icons.map_outlined,
        title: l10n.mapTitle,
        message: l10n.mapUnsupportedPlatform,
      );
    }

    return currentLocationAsync.when(
      data: (deviceLocation) {
        if (deviceLocation == null) {
          return _MapFallbackState(
            icon: Icons.location_searching_outlined,
            title: l10n.mapLocationUnavailableTitle,
            message: l10n.mapLocationUnavailableMessage,
            actionLabel: l10n.mapOpenLocationSettingsAction,
            onPressed: () async {
              await ref.read(locationServiceProvider).openLocationSettings();
            },
          );
        }

        return recommendedPlansAsync.when(
          data: (plans) {
            final origin = ApproximateCoordinate(
              latitude: deviceLocation.latitude,
              longitude: deviceLocation.longitude,
            );
            final markers = <Marker>{
              Marker(
                markerId: const MarkerId('current-area'),
                position: LatLng(origin.latitude, origin.longitude),
                infoWindow: InfoWindow(title: l10n.mapCurrentAreaLabel),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueAzure,
                ),
              ),
              ...plans.take(6).map(
                    (plan) => _planMarker(origin, plan, l10n),
                  ),
            };

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).width < 420 ? 240 : 300,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(origin.latitude, origin.longitude),
                        zoom: 12.6,
                      ),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      compassEnabled: true,
                      mapToolbarEnabled: false,
                      zoomControlsEnabled: false,
                      markers: markers,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.mapApproximateMarkerHint,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            );
          },
          loading: () => const _MapLoadingState(),
          error: (error, stackTrace) => _MapFallbackState(
            icon: Icons.map_outlined,
            title: l10n.mapTitle,
            message: error.toString(),
          ),
        );
      },
      loading: () => const _MapLoadingState(),
      error: (error, stackTrace) => _MapFallbackState(
        icon: Icons.location_disabled_outlined,
        title: l10n.mapLocationUnavailableTitle,
        message: error.toString(),
      ),
    );
  }

  Marker _planMarker(
    ApproximateCoordinate origin,
    ActivityPlan plan,
    AppLocalizations l10n,
  ) {
    final coordinate = projectApproximateCoordinate(
      origin: origin,
      seed: '${plan.id}-${plan.approximateLocation}-${plan.ownerUserId}',
      distanceKm: plan.distanceKm,
    );
    return Marker(
      markerId: MarkerId('plan-${plan.id}'),
      position: LatLng(coordinate.latitude, coordinate.longitude),
      infoWindow: InfoWindow(
        title: plan.title,
        snippet: '${plan.city} · ${plan.approximateLocation}',
      ),
    );
  }
}

class _MapLoadingState extends StatelessWidget {
  const _MapLoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).width < 420 ? 240 : 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }
}

class _MapFallbackState extends StatelessWidget {
  const _MapFallbackState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).width < 420 ? 240 : 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onPressed != null) ...[
              const SizedBox(height: AppSpacing.md),
              FilledButton.tonal(
                onPressed: onPressed,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
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
          Text('${plan.city} · ${mapPrivacyModeLabel(l10n, privacyMode)}'),
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
          Text('${plan.city} · ${mapPrivacyModeLabel(l10n, privacyMode)}'),
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
