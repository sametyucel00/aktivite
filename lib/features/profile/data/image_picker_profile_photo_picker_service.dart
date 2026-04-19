import 'package:image_picker/image_picker.dart';

import '../../../core/utils/profile_photo_policy.dart';
import 'profile_photo_picker_service.dart';

class ImagePickerProfilePhotoPickerService
    implements ProfilePhotoPickerService {
  ImagePickerProfilePhotoPickerService({
    ImagePicker? imagePicker,
  }) : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  @override
  Future<PickedProfilePhoto?> pickProfilePhoto() async {
    final photo = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1440,
    );
    if (photo == null) {
      return null;
    }

    return PickedProfilePhoto(
      fileName: sanitizedProfilePhotoFileName(photo.name),
      bytes: await photo.readAsBytes(),
    );
  }
}
