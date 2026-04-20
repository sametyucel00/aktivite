import 'package:aktivite/app/config/app_config.dart';
import 'package:aktivite/app/router.dart';
import 'package:aktivite/app/theme/app_theme.dart';
import 'package:aktivite/features/settings/application/settings_controller.dart';
import 'package:aktivite/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AktiviteApp extends ConsumerWidget {
  const AktiviteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final localeCode = ref.watch(settingsControllerProvider).localeCode;
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
