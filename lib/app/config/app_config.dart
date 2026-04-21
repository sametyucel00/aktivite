import 'package:aktivite/core/config/repository_source.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract final class AppConfig {
  static const appName = 'Togio';

  static RepositorySource get repositorySource {
    if (kIsWeb) {
      return RepositorySource.firebase;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return RepositorySource.firebase;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return RepositorySource.inMemory;
    }
  }

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];
}
