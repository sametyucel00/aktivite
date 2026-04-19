import 'dart:typed_data';

import 'package:aktivite/core/utils/profile_photo_policy.dart';
import 'package:aktivite/features/profile/application/profile_editor_controller.dart';
import 'package:aktivite/features/profile/data/profile_photo_picker_service.dart';
import 'package:aktivite/features/profile/data/profile_photo_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePicker implements ProfilePhotoPickerService {
  _FakePicker(this.photo);

  final PickedProfilePhoto? photo;

  @override
  Future<PickedProfilePhoto?> pickProfilePhoto() async => photo;
}

class _FakeStorage implements ProfilePhotoStorageService {
  @override
  Future<String?> uploadProfilePhoto({
    required String userId,
    required PickedProfilePhoto photo,
  }) async {
    return 'memory://$userId/${photo.fileName}';
  }
}

void main() {
  group('ProfileEditorController', () {
    test('uploadProfilePhoto stores photo url and preview bytes', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller =
          container.read(profileEditorControllerProvider.notifier);

      final success = await controller.uploadProfilePhoto(
        userId: 'user-1',
        picker: _FakePicker(
          PickedProfilePhoto(
            fileName: 'avatar.jpg',
            bytes: Uint8List.fromList([1, 2, 3]),
          ),
        ),
        storage: _FakeStorage(),
      );

      final state = container.read(profileEditorControllerProvider);
      expect(success, isTrue);
      expect(state.profilePhotoUrl, 'memory://user-1/avatar.jpg');
      expect(state.profilePhotoBytes, isNotNull);
      expect(state.profilePhotoIssue, isNull);
    });

    test('uploadProfilePhoto records validation issue for unsupported images',
        () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller =
          container.read(profileEditorControllerProvider.notifier);

      final success = await controller.uploadProfilePhoto(
        userId: 'user-1',
        picker: _FakePicker(
          PickedProfilePhoto(
            fileName: 'avatar.gif',
            bytes: Uint8List.fromList([1]),
          ),
        ),
        storage: _FakeStorage(),
      );

      final state = container.read(profileEditorControllerProvider);
      expect(success, isFalse);
      expect(
        state.profilePhotoIssue,
        ProfilePhotoValidationIssue.unsupportedType,
      );
    });

    test('removeProfilePhoto clears url, preview bytes, and validation issue',
        () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller =
          container.read(profileEditorControllerProvider.notifier);

      await controller.uploadProfilePhoto(
        userId: 'user-1',
        picker: _FakePicker(
          PickedProfilePhoto(
            fileName: 'avatar.jpg',
            bytes: Uint8List.fromList([1]),
          ),
        ),
        storage: _FakeStorage(),
      );
      controller.removeProfilePhoto();

      final state = container.read(profileEditorControllerProvider);
      expect(state.profilePhotoUrl, isEmpty);
      expect(state.profilePhotoBytes, isNull);
      expect(state.profilePhotoIssue, isNull);
    });
  });
}
