import 'package:aktivite/app/config/app_config.dart';
import 'package:aktivite/core/config/repository_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppConfig defaults repository source to in-memory', () {
    expect(AppConfig.repositorySource, RepositorySource.inMemory);
  });
}
