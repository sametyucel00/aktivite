import 'package:aktivite/app/app.dart';
import 'package:aktivite/core/services/app_bootstrap_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await const AppBootstrapService().initialize();
  runApp(const ProviderScope(child: AktiviteApp()));
}
