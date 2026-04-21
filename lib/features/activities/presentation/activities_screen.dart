import 'package:aktivite/app/app_routes.dart';
import 'package:aktivite/app/theme/app_breakpoints.dart';
import 'package:aktivite/app/theme/app_radii.dart';
import 'package:aktivite/core/config/repository_source.dart';
import 'package:aktivite/core/config/remote_config_keys.dart';
import 'package:aktivite/core/constants/app_spacing.dart';
import 'package:aktivite/core/enums/activity_category.dart';
import 'package:aktivite/core/enums/join_request_status.dart';
import 'package:aktivite/core/enums/plan_time_option.dart';
import 'package:aktivite/core/utils/analytics_events.dart';
import 'package:aktivite/core/utils/app_feedback.dart';
import 'package:aktivite/core/utils/localized_labels.dart';
import 'package:aktivite/features/monetization/domain/premium_tier.dart';
import 'package:aktivite/features/monetization/domain/rewarded_placement.dart';
import 'package:aktivite/features/monetization/domain/user_entitlement.dart';
import 'package:aktivite/features/activities/application/activity_composer_controller.dart';
import 'package:aktivite/features/profile/presentation/profile_screen.dart';
import 'package:aktivite/l10n/app_localizations.dart';
import 'package:aktivite/shared/models/activity_plan.dart';
import 'package:aktivite/shared/models/join_request.dart';
import 'package:aktivite/shared/models/join_request_summary.dart';
import 'package:aktivite/shared/providers/app_providers.dart';
import 'package:aktivite/shared/providers/repository_providers.dart';
import 'package:aktivite/shared/widgets/activity_plan_card.dart';
import 'package:aktivite/shared/widgets/app_section_card.dart';
import 'package:aktivite/shared/widgets/app_page_scaffold.dart';
import 'package:aktivite/shared/widgets/app_section_header.dart';
import 'package:aktivite/shared/widgets/app_surface.dart';
import 'package:aktivite/shared/widgets/async_value_view.dart';
import 'package:aktivite/shared/widgets/empty_state_view.dart';
import 'package:aktivite/shared/widgets/profile_gate_card.dart';
import 'package:aktivite/shared/widgets/route_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ActivitiesScreen extends ConsumerStatefulWidget {
  const ActivitiesScreen({super.key});

  static const routePath = AppRoutes.activities;

  @override
  ConsumerState<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends ConsumerState<ActivitiesScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _cityController;
  late final TextEditingController _approximateLocationController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _cityController = TextEditingController();
    _approximateLocationController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _approximateLocationController.dispose();
    super.dispose();
  }

  Future<void> _approveJoinRequest({
    required JoinRequest request,
    required String currentUserId,
    required AppLocalizations l10n,
  }) async {
    await ref.read(joinRequestRepositoryProvider).updateRequestStatus(
          requestId: request.id,
          status: JoinRequestStatus.approved,
        );
    if (ref.read(repositorySourceProvider) == RepositorySource.inMemory) {
      await ref.read(activityRepositoryProvider).incrementParticipantCount(
            request.activityId,
          );
      await ref.read(chatRepositoryProvider).ensureThreadForActivity(
            activityId: request.activityId,
            participantIds: [
              currentUserId,
              request.requesterId,
            ],
            initialMessagePreview: l10n.chatThreadCreatedPreview,
          );
    }
    await ref.read(analyticsServiceProvider).logEvent(
      name: AnalyticsEvents.joinRequestApproved,
      parameters: {'request_id': request.id},
    );
    await ref.read(analyticsServiceProvider).logEvent(
      name: AnalyticsEvents.chatStarted,
      parameters: {'activity_id': request.activityId},
    );
    if (!mounted) {
      return;
    }
    final approvalMessage =
        ref.read(repositorySourceProvider) == RepositorySource.firebase
            ? l10n.joinRequestApprovedFirebaseNotice
            : l10n.joinRequestApprovedLocalNotice;
    showAppSnackBar(context, approvalMessage);
  }

  Future<void> _rejectJoinRequest({
    required JoinRequest request,
    required AppLocalizations l10n,
  }) async {
    await ref.read(joinRequestRepositoryProvider).updateRequestStatus(
          requestId: request.id,
          status: JoinRequestStatus.rejected,
        );
    await ref.read(analyticsServiceProvider).logEvent(
      name: AnalyticsEvents.joinRequestRejected,
      parameters: {'request_id': request.id},
    );
    if (!mounted) {
      return;
    }
    showAppSnackBar(context, l10n.joinRequestRejectedLocalNotice);
  }

  Future<void> _boostPlan({
    required ActivityPlan plan,
    required UserEntitlement entitlement,
    required bool rewardedAdsEnabled,
    required bool premiumEnabled,
    required AppLocalizations l10n,
  }) async {
    final remoteConfig = ref.read(remoteConfigServiceProvider);
    var unlocked = entitlement.hasPremium;

    if (!unlocked && rewardedAdsEnabled) {
      final watched =
          await ref.read(rewardedAdsServiceProvider).showRewardedPlacement(
                placement: RewardedPlacement.planBoost,
              );
      if (!watched) {
        if (mounted) {
          showAppSnackBar(context, l10n.monetizationRewardedAdUnavailable);
        }
        return;
      }
      unlocked = true;
      await ref.read(analyticsServiceProvider).logEvent(
        name: AnalyticsEvents.adWatched,
        parameters: {'placement': RewardedPlacement.planBoost.name},
      );
    }

    if (!unlocked) {
      await ref.read(analyticsServiceProvider).logEvent(
        name: AnalyticsEvents.premiumClicked,
        parameters: {'placement': 'activity_boost'},
      );
      await ref.read(purchaseServiceProvider).openPremiumOffer(
            placement: 'activity_boost',
            targetTier: PremiumTier.plus,
          );
      if (mounted && premiumEnabled) {
        showAppSnackBar(context, l10n.monetizationPremiumComingSoon);
      }
      return;
    }

    final expiresAt = DateTime.now().add(
      Duration(hours: monetizationBoostHours(remoteConfig)),
    );
    await ref.read(activityRepositoryProvider).applyBoost(
          activityId: plan.id,
          expiresAt: expiresAt,
        );
    await ref.read(analyticsServiceProvider).logEvent(
      name: AnalyticsEvents.activityBoosted,
      parameters: {
        'activity_id': plan.id,
        'boost_source': entitlement.hasPremium ? 'premium' : 'rewarded_ad',
      },
    );
    if (!mounted) {
      return;
    }
    showAppSnackBar(
      context,
      l10n.activityBoostedToast(plan.title),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final plansAsync = ref.watch(ownedPlansProvider);
    final currentUserId = ref.watch(currentUserIdProvider);
    final requestsByActivityAsync =
        ref.watch(ownedJoinRequestsByActivityProvider);
    final requestSummaryAsync = ref.watch(joinRequestSummaryProvider);
    final activePlansLimit = ref.watch(effectiveActivePlansLimitProvider);
    final canCreatePlansAsync = ref.watch(canCreatePlansProvider);
    final completionAsync = ref.watch(profileCompletionProvider);
    final entitlement = ref.watch(currentUserEntitlementProvider).valueOrNull ??
        const UserEntitlement.free(userId: 'signed-out');
    final premiumEnabled = ref.watch(premiumEnabledProvider);
    final rewardedAdsEnabled = ref.watch(rewardedAdsEnabledProvider);
    final composer = ref.watch(activityComposerControllerProvider);
    final composerController =
        ref.read(activityComposerControllerProvider.notifier);
    final publishAction = canCreatePlansAsync.maybeWhen(
      data: (canCreatePlans) => plansAsync.maybeWhen(
        data: (plans) => plans.length >= activePlansLimit ||
                !composer.canSubmit ||
                !canCreatePlans
            ? null
            : () async {
                final category = composer.category.name;
                final timeOption = composer.timeOption.name;
                final timeLabel =
                    planTimeOptionLabel(l10n, composer.timeOption);
                await composerController.submit(
                  ref.read(activityRepositoryProvider),
                  ownerUserId: currentUserId ?? '',
                  timeLabel: timeLabel,
                );
                await ref.read(analyticsServiceProvider).logEvent(
                  name: AnalyticsEvents.activityPlanPublished,
                  parameters: {
                    'category': category,
                    'time_option': timeOption,
                    'time_label': timeLabel,
                    'duration_minutes': composer.durationMinutes,
                    'has_approximate_location':
                        composer.approximateLocation.isNotEmpty,
                  },
                );
                await ref.read(analyticsServiceProvider).logEvent(
                  name: AnalyticsEvents.activityCreated,
                  parameters: {
                    'category': category,
                    'time_option': timeOption,
                  },
                );
                if (!context.mounted) {
                  return;
                }
                showAppSnackBar(context, l10n.planPublishedToast);
              },
        orElse: () => null,
      ),
      orElse: () => null,
    );

    if (_titleController.text != composer.title) {
      _titleController.value = TextEditingValue(
        text: composer.title,
        selection: TextSelection.collapsed(offset: composer.title.length),
      );
    }
    if (_descriptionController.text != composer.description) {
      _descriptionController.value = TextEditingValue(
        text: composer.description,
        selection: TextSelection.collapsed(offset: composer.description.length),
      );
    }
    if (_cityController.text != composer.city) {
      _cityController.value = TextEditingValue(
        text: composer.city,
        selection: TextSelection.collapsed(offset: composer.city.length),
      );
    }
    if (_approximateLocationController.text != composer.approximateLocation) {
      _approximateLocationController.value = TextEditingValue(
        text: composer.approximateLocation,
        selection: TextSelection.collapsed(
          offset: composer.approximateLocation.length,
        ),
      );
    }

    return AppPageScaffold(
      title: l10n.activitiesTitle,
      child: ListView(
        children: [
          AppSectionHeader(
            title: l10n.activitiesTitle,
            subtitle: l10n.createPlanSubtitle,
          ),
          const SizedBox(height: AppSpacing.md),
          if (premiumEnabled) ...[
            AppSectionCard(
              title: l10n.monetizationVisibilityToolsTitle,
              subtitle: entitlement.hasPremium
                  ? l10n.monetizationVisibilityToolsPremiumSubtitle(
                      entitlement.tier == PremiumTier.pro
                          ? l10n.premiumTierPro
                          : l10n.premiumTierPlus,
                    )
                  : l10n.monetizationVisibilityToolsFreeSubtitle,
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  Chip(
                    label: Text(
                      l10n.activePlansLimit(activePlansLimit),
                    ),
                  ),
                  Chip(
                    label: Text(
                      l10n.monetizationBoostCredits(
                        entitlement.hasPremium ? entitlement.boostCredits : 0,
                      ),
                    ),
                  ),
                  if (rewardedAdsEnabled && !entitlement.hasPremium)
                    Chip(label: Text(l10n.monetizationRewardedBoost)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
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
            title: l10n.createPlanTitle,
            subtitle: l10n.createPlanSubtitle,
            child: Column(
              children: [
                TextField(
                  onChanged: composerController.setTitle,
                  controller: _titleController,
                  decoration:
                      InputDecoration(labelText: l10n.createPlanFieldTitle),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  onChanged: composerController.setDescription,
                  controller: _descriptionController,
                  minLines: 2,
                  maxLines: 3,
                  decoration: InputDecoration(
                      labelText: l10n.createPlanFieldDescription),
                ),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<ActivityCategory>(
                  initialValue: composer.category,
                  decoration:
                      InputDecoration(labelText: l10n.createPlanFieldCategory),
                  items: ActivityCategory.values
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(activityLabel(l10n, category)),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value != null) {
                      composerController.setCategory(value);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  onChanged: composerController.setCity,
                  controller: _cityController,
                  decoration:
                      InputDecoration(labelText: l10n.createPlanFieldCity),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  onChanged: composerController.setApproximateLocation,
                  controller: _approximateLocationController,
                  decoration:
                      InputDecoration(labelText: l10n.createPlanFieldLocation),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppSurface(
                  tonal: true,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final stacked =
                          constraints.maxWidth < AppBreakpoints.compact + 60;
                      final dateButton = OutlinedButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: composer.scheduledAt,
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 1),
                            ),
                            lastDate: DateTime.now().add(
                              const Duration(days: 120),
                            ),
                          );
                          if (!context.mounted || date == null) {
                            return;
                          }
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(
                              composer.scheduledAt,
                            ),
                          );
                          if (!context.mounted || time == null) {
                            return;
                          }
                          composerController.setScheduledAt(
                            DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            ),
                          );
                        },
                        child: Text(l10n.createPlanPickDateTime),
                      );

                      if (stacked) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.createPlanFieldTime,
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              DateFormat('dd MMMM, HH:mm')
                                  .format(composer.scheduledAt),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            dateButton,
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.createPlanFieldTime,
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  DateFormat('dd MMMM, HH:mm')
                                      .format(composer.scheduledAt),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          dateButton,
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<PlanTimeOption>(
                  initialValue: composer.timeOption,
                  decoration:
                      InputDecoration(labelText: l10n.createPlanFieldTime),
                  items: PlanTimeOption.values
                      .map(
                        (option) => DropdownMenuItem(
                          value: option,
                          child: Text(planTimeOptionLabel(l10n, option)),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (option) {
                    if (option != null) {
                      composerController.setTimeOption(option);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<int>(
                  initialValue: composer.durationMinutes,
                  decoration:
                      InputDecoration(labelText: l10n.createPlanFieldDuration),
                  items: activityDurationOptions()
                      .map(
                        (minutes) => DropdownMenuItem<int>(
                          value: minutes,
                          child: Text(
                            l10n.activityDurationMinutes(minutes),
                          ),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value != null) {
                      composerController.setDurationMinutes(value);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                SwitchListTile.adaptive(
                  value: composer.isIndoor,
                  onChanged: composerController.setIsIndoor,
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.createPlanFieldIndoor),
                ),
                const SizedBox(height: AppSpacing.md),
                AppSurface(
                  tonal: true,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Center(
                    child: FilledButton.icon(
                      onPressed: publishAction,
                      icon: const Icon(Icons.add),
                      label: Text(l10n.publishPlan),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppSectionHeader(
            title: l10n.activePlansTitle,
            subtitle: l10n.activePlansLimit(activePlansLimit),
          ),
          const SizedBox(height: AppSpacing.md),
          if (ref.watch(primaryOwnedPlanProvider) case final primaryPlan?) ...[
            AppSectionCard(
              title: l10n.activitiesFocusTitle,
              subtitle: l10n.activitiesFocusSubtitle,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(primaryPlan.title),
                subtitle: Text(
                  '${primaryPlan.city} - ${l10n.peopleCount(primaryPlan.participantCount, primaryPlan.maxParticipants)}',
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          ...requestSummaryAsync.when(
            data: (summary) => [
              AppSurface(
                tonal: true,
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _SummaryPill(
                      label: l10n.requestStatusPending,
                      value: summary.pending.toString(),
                    ),
                    _SummaryPill(
                      label: l10n.requestStatusApproved,
                      value: summary.approved.toString(),
                    ),
                    _SummaryPill(
                      label: l10n.requestStatusRejected,
                      value: summary.rejected.toString(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            loading: () => const <Widget>[],
            error: (error, stackTrace) => const <Widget>[],
          ),
          ...plansAsync.when(
            data: (plans) {
              if (plans.isEmpty) {
                return [
                  EmptyStateView(
                    title: l10n.activePlansEmptyTitle,
                    message: l10n.activePlansEmptyMessage,
                    action: RouteActionButton(
                      label: l10n.openExploreAction,
                      route: AppRoutes.explore,
                    ),
                  ),
                ];
              }
              return plans
                  .map(
                    (plan) => ActivityPlanCard(
                      plan: plan,
                      footer: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.hasActiveBoostAt(DateTime.now())
                                ? l10n.activityBoostedUntil(
                                    DateFormat('dd MMM, HH:mm').format(
                                      plan.boostExpiresAt!,
                                    ),
                                  )
                                : l10n.activityBoostHint,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: [
                              FilledButton.tonalIcon(
                                onPressed: () => _boostPlan(
                                  plan: plan,
                                  entitlement: entitlement,
                                  rewardedAdsEnabled: rewardedAdsEnabled,
                                  premiumEnabled: premiumEnabled,
                                  l10n: l10n,
                                ),
                                icon: const Icon(Icons.trending_up_outlined),
                                label: Text(
                                  entitlement.hasPremium
                                      ? l10n.boostPlanAction
                                      : rewardedAdsEnabled
                                          ? l10n.boostPlanWithAdAction
                                          : l10n.unlockBoostAction,
                                ),
                              ),
                              if (premiumEnabled && !entitlement.hasPremium)
                                OutlinedButton.icon(
                                  onPressed: () async {
                                    await ref
                                        .read(analyticsServiceProvider)
                                        .logEvent(
                                      name: AnalyticsEvents.premiumClicked,
                                      parameters: {'placement': 'activities'},
                                    );
                                    await ref
                                        .read(purchaseServiceProvider)
                                        .openPremiumOffer(
                                          placement: 'activities',
                                          targetTier: PremiumTier.plus,
                                        );
                                    if (context.mounted) {
                                      showAppSnackBar(
                                        context,
                                        l10n.monetizationPremiumComingSoon,
                                      );
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.workspace_premium_outlined,
                                  ),
                                  label: Text(l10n.premiumTierPlus),
                                ),
                            ],
                          ),
                        ],
                      ),
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
            title: l10n.joinRequestsTitle,
            subtitle: l10n.joinRequestsSubtitle,
            child: requestsByActivityAsync.when(
              data: (requestsByActivity) {
                final plans = plansAsync.valueOrNull ?? const [];
                if (plans.isEmpty) {
                  return Text(l10n.joinRequestsNoPlanSelected);
                }

                final planById = {
                  for (final plan in plans) plan.id: plan,
                };
                final requests = [
                  for (final entry in requestsByActivity.entries)
                    ...entry.value,
                ]..sort((left, right) {
                    final statusCompare = left.ownerListSortPriority
                        .compareTo(right.ownerListSortPriority);
                    if (statusCompare != 0) {
                      return statusCompare;
                    }
                    final leftPlan = planById[left.activityId]?.scheduledAt ??
                        DateTime.fromMillisecondsSinceEpoch(0);
                    final rightPlan = planById[right.activityId]?.scheduledAt ??
                        DateTime.fromMillisecondsSinceEpoch(0);
                    return leftPlan.compareTo(rightPlan);
                  });
                final summary = JoinRequestSummary.fromRequests(requests);
                if (requests.isEmpty) {
                  return Text(l10n.joinRequestsEmpty);
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.joinRequestsPendingCount(summary.pending),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ...requests.map(
                      (request) {
                        final plan = planById[request.activityId];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _JoinRequestReviewCard(
                            request: request,
                            planTitle: plan?.title ?? request.activityId,
                            scheduleLabel: plan == null
                                ? request.activityId
                                : DateFormat('dd MMMM, HH:mm').format(
                                    plan.scheduledAt,
                                  ),
                            requesterLabel: _requesterLabel(l10n, request),
                            repositorySource:
                                ref.read(repositorySourceProvider),
                            currentUserId: currentUserId,
                            onApprove: () => _approveJoinRequest(
                              request: request,
                              currentUserId: currentUserId ?? '',
                              l10n: l10n,
                            ),
                            onReject: () => _rejectJoinRequest(
                              request: request,
                              l10n: l10n,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
              loading: () => const AsyncLoadingView(),
              error: (error, stackTrace) =>
                  AsyncErrorView(message: error.toString()),
            ),
          ),
        ],
      ),
    );
  }

  String _requesterLabel(AppLocalizations l10n, JoinRequest request) {
    if (request.requesterId.startsWith('guest-')) {
      return l10n.guestPreviewLabel;
    }
    final compactId = request.requesterId.length <= 10
        ? request.requesterId
        : request.requesterId.substring(0, 10);
    return l10n.memberLabel(compactId);
  }
}

class _JoinRequestReviewCard extends StatelessWidget {
  const _JoinRequestReviewCard({
    required this.request,
    required this.planTitle,
    required this.scheduleLabel,
    required this.requesterLabel,
    required this.repositorySource,
    required this.currentUserId,
    required this.onApprove,
    required this.onReject,
  });

  final JoinRequest request;
  final String planTitle;
  final String scheduleLabel;
  final String requesterLabel;
  final RepositorySource repositorySource;
  final String? currentUserId;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.person_add_alt_1_outlined,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      requesterLabel,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        _MiniMetaChip(
                          icon: Icons.event_note_outlined,
                          label: planTitle,
                        ),
                        _MiniMetaChip(
                          icon: Icons.schedule_outlined,
                          label: scheduleLabel,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _JoinRequestStatusBadge(status: request.status),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(request.message),
          ),
          if (request.isApproved) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              repositorySource == RepositorySource.firebase
                  ? l10n.joinRequestApprovedFirebaseNotice
                  : l10n.joinRequestApprovedLocalNotice,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              alignment: WrapAlignment.center,
              children: [
                FilledButton.tonalIcon(
                  onPressed: request.isPending && currentUserId != null
                      ? onApprove
                      : null,
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(l10n.approveRequest),
                ),
                OutlinedButton.icon(
                  onPressed: request.isPending ? onReject : null,
                  icon: const Icon(Icons.close_rounded),
                  label: Text(l10n.rejectRequest),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}

class _MiniMetaChip extends StatelessWidget {
  const _MiniMetaChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(maxWidth: 180),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: scheme.onSecondaryContainer),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSecondaryContainer,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JoinRequestStatusBadge extends StatelessWidget {
  const _JoinRequestStatusBadge({
    required this.status,
  });

  final JoinRequestStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final (label, icon, backgroundColor, foregroundColor) = switch (status) {
      JoinRequestStatus.pending => (
          l10n.requestStatusPending,
          Icons.schedule_outlined,
          scheme.secondaryContainer,
          scheme.onSecondaryContainer,
        ),
      JoinRequestStatus.approved => (
          l10n.requestStatusApproved,
          Icons.check_circle_outline,
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
        ),
      JoinRequestStatus.rejected => (
          l10n.requestStatusRejected,
          Icons.close_rounded,
          scheme.errorContainer,
          scheme.onErrorContainer,
        ),
      JoinRequestStatus.cancelled => (
          l10n.requestStatusCancelled,
          Icons.remove_circle_outline,
          scheme.surfaceContainerHighest,
          scheme.onSurfaceVariant,
        ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 6,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: foregroundColor),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: foregroundColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
