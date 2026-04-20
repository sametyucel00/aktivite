import 'package:aktivite/core/config/repository_source.dart';
import 'package:flutter/material.dart';

abstract final class AppConfig {
  static const appName = 'Togio';
  static const repositorySource = RepositorySource.inMemory;
  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];
}
