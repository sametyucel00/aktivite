import 'package:aktivite/app/app_routes.dart';
import 'package:aktivite/core/constants/app_spacing.dart';
import 'package:aktivite/core/utils/analytics_events.dart';
import 'package:aktivite/core/utils/app_feedback.dart';
import 'package:aktivite/core/utils/event_formatters.dart';
import 'package:aktivite/core/utils/trust_event_factory.dart';
import 'package:aktivite/features/auth/application/session_controller.dart';
import 'package:aktivite/features/monetization/domain/premium_tier.dart';
import 'package:aktivite/features/monetization/domain/user_entitlement.dart';
import 'package:aktivite/features/settings/application/settings_controller.dart';
import 'package:aktivite/l10n/app_localizations.dart';
import 'package:aktivite/shared/models/moderation_event.dart';
import 'package:aktivite/shared/providers/app_providers.dart';
import 'package:aktivite/shared/providers/repository_providers.dart';
import 'package:aktivite/shared/widgets/app_section_card.dart';
import 'package:aktivite/shared/widgets/async_value_view.dart';
import 'package:aktivite/shared/widgets/app_page_scaffold.dart';
import 'package:aktivite/shared/widgets/app_section_header.dart';
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
    final entitlement = ref.watch(currentUserEntitlementProvider).valueOrNull ??
        const UserEntitlement.free(userId: 'signed-out');
    final premiumEnabled = ref.watch(premiumEnabledProvider);
    final rewardedAdsEnabled = ref.watch(rewardedAdsEnabledProvider);

    return AppPageScaffold(
      title: l10n.settingsTitle,
      child: ListView(
        children: [
          AppSectionHeader(
            title: l10n.settingsTitle,
            subtitle: l10n.settingsPreferencesSubtitle,
          ),
          const SizedBox(height: AppSpacing.md),
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
                const Divider(),
                DropdownButtonFormField<String>(
                  initialValue: preferences.localeCode,
                  decoration: InputDecoration(
                    labelText: l10n.settingsLanguageTitle,
                    helperText: l10n.settingsLanguageSubtitle,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'tr',
                      child: Text(l10n.languageTurkish),
                    ),
                    DropdownMenuItem(
                      value: 'en',
                      child: Text(l10n.languageEnglish),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.setLocaleCode(value);
                    }
                  },
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
                Chip(
                  label: Text(
                    '${l10n.settingsLanguageTitle}: ${preferences.localeCode == 'tr' ? l10n.languageTurkish : l10n.languageEnglish}',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (premiumEnabled)
            AppSectionCard(
              title: l10n.settingsPremiumTitle,
              subtitle: entitlement.hasPremium
                  ? l10n.settingsPremiumCurrentTier(
                      entitlement.tier == PremiumTier.pro
                          ? l10n.premiumTierPro
                          : l10n.premiumTierPlus,
                    )
                  : l10n.settingsPremiumSubtitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      Chip(label: Text(l10n.premiumBoosts)),
                      Chip(label: Text(l10n.premiumFilters)),
                      Chip(label: Text(l10n.premiumSlots)),
                      if (entitlement.isPro)
                        Chip(label: Text(l10n.premiumRecurringPlans)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _TierTile(
                    title: l10n.premiumTierPlus,
                    subtitle: l10n.premiumPlusSummary,
                    isCurrent: entitlement.tier == PremiumTier.plus,
                    onTap: () async {
                      await ref.read(analyticsServiceProvider).logEvent(
                        name: AnalyticsEvents.premiumClicked,
                        parameters: {'placement': 'settings_plus'},
                      );
                      await ref.read(purchaseServiceProvider).openPremiumOffer(
                            placement: 'settings_plus',
                            targetTier: PremiumTier.plus,
                          );
                      if (context.mounted) {
                        showAppSnackBar(
                          context,
                          l10n.monetizationPremiumComingSoon,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _TierTile(
                    title: l10n.premiumTierPro,
                    subtitle: l10n.premiumProSummary,
                    isCurrent: entitlement.tier == PremiumTier.pro,
                    onTap: () async {
                      await ref.read(analyticsServiceProvider).logEvent(
                        name: AnalyticsEvents.premiumClicked,
                        parameters: {'placement': 'settings_pro'},
                      );
                      await ref.read(purchaseServiceProvider).openPremiumOffer(
                            placement: 'settings_pro',
                            targetTier: PremiumTier.pro,
                          );
                      if (context.mounted) {
                        showAppSnackBar(
                          context,
                          l10n.monetizationPremiumComingSoon,
                        );
                      }
                    },
                  ),
                  if (rewardedAdsEnabled) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.monetizationRewardedAdsHint,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
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

class _TierTile extends StatelessWidget {
  const _TierTile({
    required this.title,
    required this.subtitle,
    required this.isCurrent,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isCurrent ? scheme.primaryContainer : scheme.surface,
        border: Border.all(
          color: isCurrent ? scheme.primary : scheme.outlineVariant,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: isCurrent
            ? const Icon(Icons.check_circle_outline)
            : const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
