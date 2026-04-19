import 'package:aktivite/core/config/firebase_storage_paths.dart';
import 'package:aktivite/core/utils/profile_photo_policy.dart';
import 'package:aktivite/features/profile/data/profile_photo_picker_service.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'profile_photo_storage_service.dart';

class FirebaseProfilePhotoStorageService implements ProfilePhotoStorageService {
  FirebaseProfilePhotoStorageService({
    FirebaseStorage Function()? storage,
  }) : _storage = storage ?? (() => FirebaseStorage.instance);

  final FirebaseStorage Function() _storage;

  @override
  Future<String?> uploadProfilePhoto({
    required String userId,
    required PickedProfilePhoto photo,
  }) async {
    final trimmedUserId = userId.trim();
    if (trimmedUserId.isEmpty || photo.bytes.isEmpty) {
      return null;
    }
    if (validateProfilePhoto(photo) != null) {
      return null;
    }

    final reference = _storage().ref(
      FirebaseStoragePaths.profilePhoto(
        userId: trimmedUserId,
        fileName: sanitizedProfilePhotoFileName(photo.fileName),
      ),
    );
    await reference.putData(
      photo.bytes,
      SettableMetadata(
        contentType: _contentTypeFor(photo.fileName),
      ),
    );
    return reference.getDownloadURL();
  }

  String _contentTypeFor(String fileName) {
    final normalized = fileName.toLowerCase();
    if (normalized.endsWith('.png')) {
      return 'image/png';
    }
    if (normalized.endsWith('.webp')) {
      return 'image/webp';
    }
    return 'image/jpeg';
  }
}
