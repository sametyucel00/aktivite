import 'package:aktivite/app/config/app_config.dart';
import 'package:aktivite/app/router.dart';
import 'package:aktivite/app/theme/app_theme.dart';
import 'package:aktivite/core/config/repository_source.dart';
import 'package:aktivite/features/auth/application/session_controller.dart';
import 'package:aktivite/features/auth/domain/app_session.dart';
import 'package:aktivite/features/settings/application/settings_controller.dart';
import 'package:aktivite/l10n/app_localizations.dart';
import 'package:aktivite/shared/models/user_preferences.dart';
import 'package:aktivite/shared/providers/repository_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AktiviteApp extends ConsumerStatefulWidget {
  const AktiviteApp({super.key});

  @override
  ConsumerState<AktiviteApp> createState() => _AktiviteAppState();
}

class _AktiviteAppState extends ConsumerState<AktiviteApp> {
  ProviderSubscription<AppSession>? _sessionSubscription;

  @override
  void initState() {
    super.initState();
    _sessionSubscription = ref.listenManual<AppSession>(
      sessionControllerProvider,
      (_, next) async {
        final repositorySource = ref.read(repositorySourceProvider);
        final notificationsEnabled =
            ref.read(settingsControllerProvider).notificationsAllowed;
        final notificationSyncService =
            ref.read(notificationSyncServiceProvider);

        if (repositorySource != RepositorySource.firebase ||
            !notificationsEnabled ||
            !next.isAuthenticated ||
            next.userId == null) {
          await notificationSyncService.dispose();
          return;
        }

        await notificationSyncService.syncForUser(next.userId!);
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _sessionSubscription?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final preferences = ref.watch(settingsControllerProvider);
    final localeCode = preferences.localeCode;

    ref.listen<UserPreferences>(
      settingsControllerProvider,
      (_, next) async {
        final session = ref.read(sessionControllerProvider);
        final notificationSyncService =
            ref.read(notificationSyncServiceProvider);
        final repositorySource = ref.read(repositorySourceProvider);
        if (repositorySource != RepositorySource.firebase ||
            !next.notificationsAllowed ||
            !session.isAuthenticated ||
            session.userId == null) {
          await notificationSyncService.dispose();
          return;
        }

        await notificationSyncService.syncForUser(session.userId!);
      },
    );
    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      locale: Locale(localeCode),
      supportedLocales: AppConfig.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: router,
    );
  }
}
