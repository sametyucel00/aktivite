import 'package:aktivite/app/app_routes.dart';
import 'package:aktivite/core/constants/app_spacing.dart';
import 'package:aktivite/core/utils/analytics_events.dart';
import 'package:aktivite/core/utils/event_formatters.dart';
import 'package:aktivite/core/utils/trust_event_factory.dart';
import 'package:aktivite/features/auth/application/session_controller.dart';
import 'package:aktivite/features/settings/application/settings_controller.dart';
import 'package:aktivite/l10n/app_localizations.dart';
import 'package:aktivite/shared/models/moderation_event.dart';
import 'package:aktivite/shared/providers/app_providers.dart';
import 'package:aktivite/shared/providers/repository_providers.dart';
import 'package:aktivite/shared/widgets/app_section_card.dart';
import 'package:aktivite/shared/widgets/async_value_view.dart';
import 'package:aktivite/shared/widgets/route_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const routePath = AppRoutes.settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final preferences = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final analyticsEventsAsync = ref.watch(analyticsEventsProvider);
    final trustEventsAsync = ref.watch(currentUserModerationEventsProvider);
    final analyticsSummaryAsync = ref.watch(analyticsSignalSummaryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          AppSectionCard(
            title: l10n.settingsPreferences,
            subtitle: l10n.settingsPreferencesSubtitle,
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  value: preferences.notificationsAllowed,
                  onChanged: (value) {
                    controller.setNotificationsEnabled(value);
                    ref.read(analyticsServiceProvider).logEvent(
                      name: AnalyticsEvents.settingsNotificationsToggled,
                      parameters: {'enabled': value},
                    );
                  },
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.settingsNotifications),
                ),
                SwitchListTile.adaptive(
                  value: preferences.sharesApproximateLocation,
                  onChanged: (value) {
                    controller.setApproximateLocationEnabled(value);
                    ref.read(analyticsServiceProvider).logEvent(
                      name: AnalyticsEvents.settingsLocationPrivacyToggled,
                      parameters: {'enabled': value},
                    );
                  },
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.settingsApproximateLocation),
                ),
                SwitchListTile.adaptive(
                  value: preferences.safeMeetupRemindersActive,
                  onChanged: (value) async {
                    controller.setSafeMeetupRemindersEnabled(value);
                    await ref.read(analyticsServiceProvider).logEvent(
                      name: AnalyticsEvents.settingsSafeMeetupToggled,
                      parameters: {'enabled': value},
                    );
                    final userId = ref.read(currentUserIdProvider);
                    if (userId == null) {
                      return;
                    }
                    final trustEvents = trustEventsAsync.valueOrNull ??
                        const <ModerationEvent>[];
                    if (!shouldCreateSafeMeetupReminderTrustEvent(
                      userId: userId,
                      enabled: value,
                      existingEvents: trustEvents,
                    )) {
                      return;
                    }
                    await ref
                        .read(moderationRepositoryProvider)
                        .createTrustEvent(
                          createSafeMeetupReminderTrustEvent(
                            subjectUserId: userId,
                          ),
                        );
                  },
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.settingsSafeMeetupReminders),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppSectionCard(
            title: l10n.settingsSummaryTitle,
            subtitle: l10n.settingsSummarySubtitle,
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                Chip(
                  label: Text(
                    '${l10n.settingsNotifications}: ${boolStateLabel(l10n, preferences.notificationsAllowed)}',
                  ),
                ),
                Chip(
                  label: Text(
                    '${l10n.settingsApproximateLocation}: ${boolStateLabel(l10n, preferences.sharesApproximateLocation)}',
                  ),
                ),
                Chip(
                  label: Text(
                    '${l10n.settingsSafeMeetupReminders}: ${boolStateLabel(l10n, preferences.safeMeetupRemindersActive)}',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppSectionCard(
            title: l10n.profileTitle,
            subtitle: l10n.settingsProfileShortcutSubtitle,
            child: Align(
              alignment: Alignment.centerLeft,
              child: RouteActionButton(
                label: l10n.openProfileAction,
                route: AppRoutes.profile,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppSectionCard(
            title: l10n.settingsSafetyLinkTitle,
            subtitle: l10n.settingsSafetyLinkSubtitle,
            child: Align(
              alignment: Alignment.centerLeft,
              child: RouteActionButton(
                label: l10n.openSafetyCenterAction,
                route: AppRoutes.safety,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...analyticsSummaryAsync.when(
            data: (summary) => [
              AppSectionCard(
                title: l10n.settingsSignalsSummaryTitle,
                subtitle: l10n.settingsSignalsSummarySubtitle,
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    Chip(
                        label: Text(
                            l10n.analyticsSummaryAuth(summary.authActions))),
                    Chip(
                      label: Text(
                        l10n.analyticsSummarySafety(summary.safetyActions),
                      ),
                    ),
                    Chip(
                      label: Text(
                        l10n.analyticsSummaryCoordination(
                          summary.coordinationActions,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            loading: () => const <Widget>[],
            error: (error, stackTrace) => const <Widget>[],
          ),
          AppSectionCard(
            title: l10n.settingsSignalsTitle,
            subtitle: l10n.settingsSignalsSubtitle,
            child: analyticsEventsAsync.when(
              data: (events) {
                if (events.isEmpty) {
                  return Text(l10n.settingsSignalsEmpty);
                }
                return Column(
                  children: events
                      .take(5)
                      .map(
                        (event) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(analyticsEventTitle(l10n, event)),
                          subtitle: Text(formatTimeLabel(event.loggedAt)),
                        ),
                      )
                      .toList(growable: false),
                );
              },
              loading: () => const AsyncLoadingView(),
              error: (error, stackTrace) =>
                  AsyncErrorView(message: error.toString()),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(
            onPressed: () async {
              await ref.read(analyticsServiceProvider).logEvent(
                    name: AnalyticsEvents.sessionSignedOut,
                  );
              await ref.read(sessionControllerProvider.notifier).signOut();
            },
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );
  }
}
