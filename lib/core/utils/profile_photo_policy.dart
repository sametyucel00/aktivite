import 'package:aktivite/features/profile/data/profile_photo_picker_service.dart';

enum ProfilePhotoValidationIssue {
  empty,
  unsupportedType,
  tooLarge,
}

const int maxProfilePhotoBytes = 5 * 1024 * 1024;

const Set<String> supportedProfilePhotoExtensions = {
  'jpg',
  'jpeg',
  'png',
  'webp',
};

ProfilePhotoValidationIssue? validateProfilePhoto(PickedProfilePhoto photo) {
  if (photo.bytes.isEmpty) {
    return ProfilePhotoValidationIssue.empty;
  }

  if (photo.bytes.length > maxProfilePhotoBytes) {
    return ProfilePhotoValidationIssue.tooLarge;
  }

  if (!supportedProfilePhotoExtensions.contains(
    profilePhotoExtension(photo.fileName),
  )) {
    return ProfilePhotoValidationIssue.unsupportedType;
  }

  return null;
}

String profilePhotoExtension(String fileName) {
  final normalized = fileName.trim().toLowerCase();
  final lastDot = normalized.lastIndexOf('.');
  if (lastDot < 0 || lastDot == normalized.length - 1) {
    return '';
  }
  return normalized.substring(lastDot + 1);
}

String sanitizedProfilePhotoFileName(String fileName) {
  final trimmed = fileName.trim();
  if (trimmed.isEmpty) {
    return 'profile-photo.jpg';
  }

  final sanitized = trimmed.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '-');
  if (profilePhotoExtension(sanitized).isEmpty) {
    return '$sanitized.jpg';
  }
  return sanitized;
}
