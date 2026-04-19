import 'package:aktivite/core/config/repository_source.dart';
import 'package:flutter/material.dart';

abstract final class AppConfig {
  static const appName = 'Aktivite';
  static const repositorySource = RepositorySource.inMemory;
  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];
}
