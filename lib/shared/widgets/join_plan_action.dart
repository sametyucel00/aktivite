import 'package:aktivite/core/constants/app_spacing.dart';
import 'package:aktivite/core/utils/app_feedback.dart';
import 'package:aktivite/core/utils/join_plan_status.dart';
import 'package:aktivite/features/activities/application/join_request_composer_controller.dart';
import 'package:aktivite/features/auth/application/session_controller.dart';
import 'package:aktivite/l10n/app_localizations.dart';
import 'package:aktivite/shared/models/activity_plan.dart';
import 'package:aktivite/shared/models/join_request.dart';
import 'package:aktivite/shared/providers/app_providers.dart';
import 'package:aktivite/shared/providers/repository_providers.dart';
import 'package:aktivite/shared/widgets/async_value_view.dart';
import 'package:aktivite/shared/widgets/join_request_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum JoinPlanActionStyle { tonal, text }

class JoinPlanStatusText extends ConsumerWidget {
  const JoinPlanStatusText({
    required this.plan,
    this.textStyle,
    super.key,
  });

  final ActivityPlan plan;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionControllerProvider);
    final requestsAsync = ref.watch(joinRequestsProvider(plan.id));

    return requestsAsync.when(
      data: (requests) {
        final label = joinPlanStatusLabel(
          l10n: l10n,
          requests: requests,
          userId: session.userId,
          plan: plan,
        );
        if (label.isEmpty) {
          return const SizedBox.shrink();
        }
        return Text(
          label,
          style: textStyle ?? Theme.of(context).textTheme.bodySmall,
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) =>
          Text(error.toString(), style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

class JoinPlanAction extends ConsumerWidget {
  const JoinPlanAction({
    required this.plan,
    required this.analyticsEventName,
    this.analyticsParameters = const <String, Object?>{},
    this.style = JoinPlanActionStyle.tonal,
    this.showStatus = true,
    super.key,
  });

  final ActivityPlan plan;
  final String analyticsEventName;
  final Map<String, Object?> analyticsParameters;
  final JoinPlanActionStyle style;
  final bool showStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionControllerProvider);
    final profileAsync = ref.watch(currentUserProfileProvider);
    final joinRequestComposer =
        ref.watch(joinRequestComposerControllerProvider);
    final requestsAsync = ref.watch(joinRequestsProvider(plan.id));

    return requestsAsync.when(
      data: (requests) {
        final statusLabel = joinPlanStatusLabel(
          l10n: l10n,
          requests: requests,
          userId: session.userId,
          plan: plan,
        );
        if (statusLabel.isNotEmpty) {
          if (!showStatus) {
            return const SizedBox.shrink();
          }
          if (session.userId != null &&
              plan.ownerUserId != session.userId &&
              !plan.hasCapacity &&
              currentUserJoinRequest(requests, session.userId) == null) {
            return _JoinPlanUnavailableAction(
              label: statusLabel,
              style: style,
            );
          }
          return _JoinRequestStatusActions(
            label: statusLabel,
            request: currentUserJoinRequest(requests, session.userId),
          );
        }

        final canRequest = profileAsync.valueOrNull?.canCreatePlans ?? false;
        final onPressed = !canSubmitJoinRequest(
          plan: plan,
          requests: requests,
          userId: session.userId,
          canCreatePlans: canRequest,
        )
            ? null
            : () async {
                final message = await showJoinRequestDialog(
                  context,
                  l10n: l10n,
                  initialMessage: joinRequestComposer.initialMessage(l10n),
                  presetMessages: joinRequestComposer.presetMessages(l10n),
                  isValid: joinRequestComposer.isValid,
                );
                if (!joinRequestComposer.isValid(message)) {
                  return;
                }
                final normalizedMessage =
                    joinRequestComposer.normalizeMessage(message);
                await joinRequestComposer.submit(
                  repository: ref.read(joinRequestRepositoryProvider),
                  activityId: plan.id,
                  message: normalizedMessage,
                );
                await ref.read(analyticsServiceProvider).logEvent(
                  name: analyticsEventName,
                  parameters: {
                    'activity_id': plan.id,
                    'used_default_message': joinRequestComposer
                        .isDefaultMessage(l10n, normalizedMessage),
                    ...analyticsParameters,
                  },
                );
                if (!context.mounted) {
                  return;
                }
                showAppSnackBar(context, l10n.joinRequestSent);
              };

        switch (style) {
          case JoinPlanActionStyle.tonal:
            return FilledButton.tonal(
              onPressed: onPressed,
              child: Text(l10n.joinPlan),
            );
          case JoinPlanActionStyle.text:
            return TextButton(
              onPressed: onPressed,
              child: Text(l10n.joinPlan),
            );
        }
      },
      loading: () => const AsyncLoadingView(),
      error: (error, stackTrace) => AsyncErrorView(message: error.toString()),
    );
  }
}

class _JoinPlanUnavailableAction extends StatelessWidget {
  const _JoinPlanUnavailableAction({
    required this.label,
    required this.style,
  });

  final String label;
  final JoinPlanActionStyle style;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        switch (style) {
          JoinPlanActionStyle.tonal => FilledButton.tonal(
              onPressed: null,
              child: Text(l10n.activityStatusFull),
            ),
          JoinPlanActionStyle.text => TextButton(
              onPressed: null,
              child: Text(l10n.activityStatusFull),
            ),
        },
      ],
    );
  }
}

class _JoinRequestStatusActions extends ConsumerStatefulWidget {
  const _JoinRequestStatusActions({
    required this.label,
    required this.request,
  });

  final String label;
  final JoinRequest? request;

  @override
  ConsumerState<_JoinRequestStatusActions> createState() =>
      _JoinRequestStatusActionsState();
}

class _JoinRequestStatusActionsState
    extends ConsumerState<_JoinRequestStatusActions> {
  bool _isCancelling = false;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider);
    final canCancel = widget.request != null &&
        canCancelJoinRequest(
          request: widget.request!,
          userId: session.userId,
        );

    if (!canCancel) {
      return Text(
        widget.label,
        style: Theme.of(context).textTheme.bodySmall,
      );
    }

    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        TextButton(
          onPressed: _isCancelling
              ? null
              : () async {
                  setState(() {
                    _isCancelling = true;
                  });
                  try {
                    await ref
                        .read(joinRequestRepositoryProvider)
                        .cancelJoinRequest(
                          requestId: widget.request!.id,
                        );
                    if (!context.mounted) {
                      return;
                    }
                    showAppSnackBar(context, l10n.joinRequestCancelled);
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isCancelling = false;
                      });
                    }
                  }
                },
          child: _isCancelling
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.joinRequestCancel),
        ),
      ],
    );
  }
}
