import 'package:aktivite/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

class AppBootstrapService {
  const AppBootstrapService();

  Future<void> initialize() async {
    if (Firebase.apps.isNotEmpty) {
      return;
    }

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
