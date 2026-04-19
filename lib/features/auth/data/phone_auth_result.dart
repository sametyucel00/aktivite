enum PhoneAuthStatus {
  signedIn,
  codeSent,
  unsupported,
  failed,
}

enum PhoneAuthFailureReason {
  invalidPhoneNumber,
  invalidCode,
  expiredCode,
  tooManyRequests,
  sessionExpired,
  unknown,
}

class PhoneAuthResult {
  const PhoneAuthResult._({
    required this.status,
    this.verificationId,
    this.message,
    this.failureReason,
  });

  const PhoneAuthResult.signedIn()
      : this._(
          status: PhoneAuthStatus.signedIn,
        );

  const PhoneAuthResult.codeSent({
    required String verificationId,
  }) : this._(
          status: PhoneAuthStatus.codeSent,
          verificationId: verificationId,
        );

  const PhoneAuthResult.unsupported({
    String? message,
  }) : this._(
          status: PhoneAuthStatus.unsupported,
          message: message,
        );

  const PhoneAuthResult.failed({
    String? message,
    PhoneAuthFailureReason failureReason = PhoneAuthFailureReason.unknown,
  }) : this._(
          status: PhoneAuthStatus.failed,
          message: message,
          failureReason: failureReason,
        );

  final PhoneAuthStatus status;
  final String? verificationId;
  final String? message;
  final PhoneAuthFailureReason? failureReason;

  bool get isSignedIn => status == PhoneAuthStatus.signedIn;

  bool get isCodeSent => status == PhoneAuthStatus.codeSent;

  bool get isUnsupported => status == PhoneAuthStatus.unsupported;

  bool get isFailed => status == PhoneAuthStatus.failed;
}
