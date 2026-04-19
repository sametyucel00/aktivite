import 'package:aktivite/core/config/repository_source.dart';
import 'package:aktivite/features/profile/data/in_memory_profile_photo_storage_service.dart';
import 'package:aktivite/features/profile/data/profile_photo_picker_service.dart';
import 'package:aktivite/shared/providers/profile_media_providers.dart';
import 'package:aktivite/shared/providers/repository_providers.dart';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('profile media providers', () {
    test('default source resolves image picker and in-memory storage', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        container
            .read(profilePhotoPickerServiceProvider)
            .runtimeType
            .toString(),
        'ImagePickerProfilePhotoPickerService',
      );
      expect(
        container
            .read(profilePhotoStorageServiceProvider)
            .runtimeType
            .toString(),
        'InMemoryProfilePhotoStorageService',
      );
    });

    test('firebase source resolves firebase storage service', () {
      final container = ProviderContainer(
        overrides: [
          repositorySourceProvider.overrideWith((ref) {
            return RepositorySource.firebase;
          }),
        ],
      );
      addTearDown(container.dispose);

      expect(
        container
            .read(profilePhotoPickerServiceProvider)
            .runtimeType
            .toString(),
        'ImagePickerProfilePhotoPickerService',
      );
      expect(
        container
            .read(profilePhotoStorageServiceProvider)
            .runtimeType
            .toString(),
        'FirebaseProfilePhotoStorageService',
      );
    });

    test('in-memory storage rejects unsupported photo payloads', () async {
      final storage = InMemoryProfilePhotoStorageService();

      final url = await storage.uploadProfilePhoto(
        userId: 'user-1',
        photo: PickedProfilePhoto(
          fileName: 'avatar.gif',
          bytes: Uint8List.fromList([1, 2, 3]),
        ),
      );

      expect(url, isNull);
    });
  });
}
