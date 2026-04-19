import 'dart:typed_data';

import 'package:aktivite/core/utils/profile_photo_policy.dart';
import 'package:aktivite/features/profile/data/profile_photo_picker_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('profile photo policy', () {
    test('accepts supported non-empty images under the size limit', () {
      final photo = PickedProfilePhoto(
        fileName: 'friendly photo.JPG',
        bytes: Uint8List.fromList([1, 2, 3]),
      );

      expect(validateProfilePhoto(photo), isNull);
      expect(
        sanitizedProfilePhotoFileName(photo.fileName),
        'friendly-photo.JPG',
      );
    });

    test('rejects empty, unsupported, and oversized photos', () {
      expect(
        validateProfilePhoto(
          PickedProfilePhoto(fileName: 'photo.jpg', bytes: Uint8List(0)),
        ),
        ProfilePhotoValidationIssue.empty,
      );
      expect(
        validateProfilePhoto(
          PickedProfilePhoto(
            fileName: 'photo.gif',
            bytes: Uint8List.fromList([1]),
          ),
        ),
        ProfilePhotoValidationIssue.unsupportedType,
      );
      expect(
        validateProfilePhoto(
          PickedProfilePhoto(
            fileName: 'photo.jpg',
            bytes: Uint8List(maxProfilePhotoBytes + 1),
          ),
        ),
        ProfilePhotoValidationIssue.tooLarge,
      );
    });
  });
}
