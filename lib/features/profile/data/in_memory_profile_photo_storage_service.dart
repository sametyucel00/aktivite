import 'package:aktivite/features/profile/data/profile_photo_picker_service.dart';
import 'package:aktivite/core/utils/profile_photo_policy.dart';

import 'profile_photo_storage_service.dart';

class InMemoryProfilePhotoStorageService implements ProfilePhotoStorageService {
  @override
  Future<String?> uploadProfilePhoto({
    required String userId,
    required PickedProfilePhoto photo,
  }) async {
    if (userId.trim().isEmpty || photo.bytes.isEmpty) {
      return null;
    }
    if (validateProfilePhoto(photo) != null) {
      return null;
    }
    return 'memory://profile-photo/$userId/${sanitizedProfilePhotoFileName(photo.fileName)}';
  }
}
