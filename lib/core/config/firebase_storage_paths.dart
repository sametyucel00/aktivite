class FirebaseStoragePaths {
  const FirebaseStoragePaths._();

  static String profilePhoto({
    required String userId,
    required String fileName,
  }) {
    return 'users/$userId/profilePhotos/$fileName';
  }

  static String verificationMedia({
    required String userId,
    required String fileName,
  }) {
    return 'users/$userId/verification/$fileName';
  }

  static String reportAttachment({
    required String reportId,
    required String fileName,
  }) {
    return 'reports/$reportId/attachments/$fileName';
  }
}
