import 'package:aktivite/features/profile/data/profile_photo_picker_service.dart';

abstract class ProfilePhotoStorageService {
  Future<String?> uploadProfilePhoto({
    required String userId,
    required PickedProfilePhoto photo,
  });
}
