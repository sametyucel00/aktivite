import 'package:aktivite/core/config/repository_source.dart';
import 'package:aktivite/features/profile/data/firebase_profile_photo_storage_service.dart';
import 'package:aktivite/features/profile/data/image_picker_profile_photo_picker_service.dart';
import 'package:aktivite/features/profile/data/in_memory_profile_photo_storage_service.dart';
import 'package:aktivite/features/profile/data/profile_photo_picker_service.dart';
import 'package:aktivite/features/profile/data/profile_photo_storage_service.dart';
import 'package:aktivite/shared/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profilePhotoPickerServiceProvider = Provider<ProfilePhotoPickerService>(
  (ref) => ImagePickerProfilePhotoPickerService(),
);

final profilePhotoStorageServiceProvider = Provider<ProfilePhotoStorageService>(
  (ref) {
    switch (ref.watch(repositorySourceProvider)) {
      case RepositorySource.inMemory:
        return InMemoryProfilePhotoStorageService();
      case RepositorySource.firebase:
        return FirebaseProfilePhotoStorageService();
    }
  },
);
