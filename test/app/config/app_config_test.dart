import 'package:aktivite/app/config/app_config.dart';
import 'package:aktivite/core/config/repository_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppConfig defaults repository source to firebase on mobile targets',
      () {
    expect(AppConfig.repositorySource, RepositorySource.firebase);
  });
}
