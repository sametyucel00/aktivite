import 'dart:typed_data';

abstract class ProfilePhotoPickerService {
  Future<PickedProfilePhoto?> pickProfilePhoto();
}

class PickedProfilePhoto {
  const PickedProfilePhoto({
    required this.fileName,
    required this.bytes,
  });

  final String fileName;
  final Uint8List bytes;
}
