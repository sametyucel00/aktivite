import 'package:aktivite/app/app_routes.dart';
import 'package:aktivite/core/config/repository_source.dart';
import 'package:aktivite/core/config/sample_ids.dart';
import 'package:aktivite/core/constants/app_spacing.dart';
import 'package:aktivite/core/enums/activity_category.dart';
import 'package:aktivite/core/enums/join_request_status.dart';
import 'package:aktivite/core/enums/plan_time_option.dart';
import 'package:aktivite/core/utils/analytics_events.dart';
import 'package:aktivite/core/utils/app_feedback.dart';
import 'package:aktivite/core/utils/localized_labels.dart';
import 'package:aktivite/features/activities/application/activity_composer_controller.dart';
import 'package:aktivite/features/profile/presentation/profile_screen.dart';
import 'package:aktivite/l10n/app_localizations.dart';
import 'package:aktivite/shared/models/join_request.dart';
import 'package:aktivite/shared/models/join_request_summary.dart';
import 'package:aktivite/shared/providers/app_providers.dart';
import 'package:aktivite/shared/providers/repository_providers.dart';
import 'package:aktivite/shared/widgets/activity_plan_card.dart';
import 'package:aktivite/shared/widgets/app_section_card.dart';
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
              SampleIds.currentUser,
              request.requesterId,
            ],
            initialMessagePreview: l10n.chatThreadCreatedPreview,
          );
    }
    await ref.read(analyticsServiceProvider).logEvent(
      name: AnalyticsEvents.joinRequestApproved,
      parameters: {'request_id': request.id},
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final plansAsync = ref.watch(ownedPlansProvider);
    final primaryActivityId = ref.watch(primaryActivityIdProvider);
    final primaryPlan = ref.watch(primaryOwnedPlanProvider);
    final requestSummaryAsync = ref.watch(joinRequestSummaryProvider);
    final requestsAsync = primaryActivityId == null
        ? const AsyncValue<List<JoinRequest>>.data([])
        : ref.watch(joinRequestsProvider(primaryActivityId));
    final activePlansLimit = ref.watch(activePlansLimitProvider);
    final canCreatePlansAsync = ref.watch(canCreatePlansProvider);
    final completionAsync = ref.watch(profileCompletionProvider);
    final composer = ref.watch(activityComposerControllerProvider);
    final composerController =
        ref.read(activityComposerControllerProvider.notifier);

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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.activitiesTitle)),
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
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.createPlanFieldTime),
                  subtitle: Text(
                    DateFormat('dd MMMM, HH:mm').format(composer.scheduledAt),
                  ),
                  trailing: OutlinedButton(
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
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.activePlansTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.activePlansLimit(activePlansLimit),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          if (primaryPlan != null) ...[
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
              AppSectionCard(
                title: l10n.joinRequestsTitle,
                subtitle:
                    '${l10n.requestStatusPending}: ${summary.pending} | ${l10n.requestStatusApproved}: ${summary.approved} | ${l10n.requestStatusRejected}: ${summary.rejected}',
                child: const SizedBox.shrink(),
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
                  .map((plan) => ActivityPlanCard(plan: plan))
                  .toList(growable: false);
            },
            loading: () => const [AsyncLoadingView()],
            error: (error, stackTrace) =>
                [AsyncErrorView(message: error.toString())],
          ),
          const SizedBox(height: AppSpacing.md),
          AppSectionCard(
            title: l10n.joinRequestsTitle,
            subtitle: primaryActivityId == null
                ? l10n.joinRequestsNoPlanSelected
                : l10n.joinRequestsSubtitle,
            child: requestsAsync.when(
              data: (requests) {
                final sortedRequests = [...requests]..sort((left, right) {
                    final statusCompare = left.ownerListSortPriority
                        .compareTo(right.ownerListSortPriority);
                    if (statusCompare != 0) {
                      return statusCompare;
                    }
                    return left.requesterId.compareTo(right.requesterId);
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
                    if (primaryPlan != null) ...[
                      Text(
                        l10n.joinRequestsPlanContext(
                          primaryPlan.title,
                          DateFormat('dd MMMM, HH:mm')
                              .format(primaryPlan.scheduledAt),
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    ...sortedRequests.map(
                      (request) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _requesterLabel(l10n, request),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        primaryPlan?.title ??
                                            request.activityId,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                _JoinRequestStatusBadge(status: request.status),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(request.message),
                            if (request.isApproved) ...[
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                ref.read(repositorySourceProvider) ==
                                        RepositorySource.firebase
                                    ? l10n.joinRequestApprovedFirebaseNotice
                                    : l10n.joinRequestApprovedLocalNotice,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                            const SizedBox(height: AppSpacing.sm),
                            Wrap(
                              spacing: AppSpacing.sm,
                              children: [
                                FilledButton.tonal(
                                  onPressed: request.isPending
                                      ? () => _approveJoinRequest(
                                            request: request,
                                            l10n: l10n,
                                          )
                                      : null,
                                  child: Text(l10n.approveRequest),
                                ),
                                OutlinedButton(
                                  onPressed: request.isPending
                                      ? () => _rejectJoinRequest(
                                            request: request,
                                            l10n: l10n,
                                          )
                                      : null,
                                  child: Text(l10n.rejectRequest),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
      floatingActionButton: plansAsync.maybeWhen(
        data: (plans) => FloatingActionButton.extended(
          onPressed: canCreatePlansAsync.maybeWhen(
            data: (canCreatePlans) => plans.length >= activePlansLimit ||
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
                    if (!context.mounted) {
                      return;
                    }
                    showAppSnackBar(context, l10n.planPublishedToast);
                  },
            orElse: () => null,
          ),
          icon: const Icon(Icons.add),
          label: Text(l10n.publishPlan),
        ),
        orElse: () => null,
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
