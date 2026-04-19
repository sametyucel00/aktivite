import 'package:aktivite/features/auth/data/phone_auth_result.dart';
import 'package:aktivite/features/auth/application/session_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthPhoneFormError {
  empty,
  invalid,
  codeEmpty,
  codeInvalid,
  codeExpired,
  tooManyRequests,
  unsupported,
  failed,
}

class AuthPhoneFormState {
  const AuthPhoneFormState({
    required this.phoneNumber,
    required this.smsCode,
    required this.isSubmitting,
    required this.error,
    required this.pendingVerificationId,
  });

  const AuthPhoneFormState.initial()
      : phoneNumber = '',
        smsCode = '',
        isSubmitting = false,
        error = null,
        pendingVerificationId = null;

  final String phoneNumber;
  final String smsCode;
  final bool isSubmitting;
  final AuthPhoneFormError? error;
  final String? pendingVerificationId;

  String get normalizedPhoneNumber => normalizePhoneNumber(phoneNumber);

  bool get canSubmit =>
      validatePhoneNumber(phoneNumber) == null && !isSubmitting;

  bool get canSubmitCode =>
      pendingVerificationId != null &&
      validateSmsCode(smsCode) == null &&
      !isSubmitting;

  bool get canResendCode => pendingVerificationId != null && !isSubmitting;

  AuthPhoneFormState copyWith({
    String? phoneNumber,
    String? smsCode,
    bool? isSubmitting,
    AuthPhoneFormError? error,
    bool clearError = false,
    String? pendingVerificationId,
    bool clearPendingVerification = false,
    bool clearSmsCode = false,
  }) {
    return AuthPhoneFormState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      smsCode: clearSmsCode ? '' : smsCode ?? this.smsCode,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : error ?? this.error,
      pendingVerificationId: clearPendingVerification
          ? null
          : pendingVerificationId ?? this.pendingVerificationId,
    );
  }
}

class AuthPhoneFormController extends Notifier<AuthPhoneFormState> {
  @override
  AuthPhoneFormState build() {
    return const AuthPhoneFormState.initial();
  }

  void setPhoneNumber(String value) {
    state = state.copyWith(
      phoneNumber: value,
      clearError: true,
      clearPendingVerification: true,
      clearSmsCode: true,
    );
  }

  void setSmsCode(String value) {
    state = state.copyWith(
      smsCode: value,
      clearError: true,
    );
  }

  Future<bool> submit() async {
    final validationError = validatePhoneNumber(state.phoneNumber);
    if (validationError != null) {
      state = state.copyWith(error: validationError);
      return false;
    }

    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearPendingVerification: true,
    );

    try {
      final result = await ref
          .read(sessionControllerProvider.notifier)
          .signInWithPhone(state.normalizedPhoneNumber);
      return _applyResult(result);
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        error: AuthPhoneFormError.failed,
      );
      return false;
    }
  }

  Future<bool> submitCode() async {
    final verificationId = state.pendingVerificationId;
    if (verificationId == null) {
      state = state.copyWith(error: AuthPhoneFormError.failed);
      return false;
    }

    final validationError = validateSmsCode(state.smsCode);
    if (validationError != null) {
      state = state.copyWith(error: validationError);
      return false;
    }

    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
    );

    try {
      final result =
          await ref.read(sessionControllerProvider.notifier).confirmSmsCode(
                verificationId: verificationId,
                smsCode: normalizeSmsCode(state.smsCode),
              );
      return _applyResult(result);
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        error: AuthPhoneFormError.failed,
      );
      return false;
    }
  }

  Future<bool> resendCode() {
    if (!state.canResendCode) {
      return Future<bool>.value(false);
    }
    return submit();
  }

  bool _applyResult(PhoneAuthResult result) {
    if (result.isSignedIn) {
      state = state.copyWith(
        isSubmitting: false,
        clearError: true,
        clearPendingVerification: true,
        clearSmsCode: true,
      );
      return true;
    }

    if (result.isCodeSent) {
      state = state.copyWith(
        isSubmitting: false,
        clearError: true,
        pendingVerificationId: result.verificationId,
      );
      return false;
    }

    if (result.isUnsupported) {
      state = state.copyWith(
        isSubmitting: false,
        error: AuthPhoneFormError.unsupported,
      );
      return false;
    }

    if (result.isFailed) {
      state = state.copyWith(
        isSubmitting: false,
        error: _mapFailureReason(result.failureReason),
      );
      return false;
    }

    state = state.copyWith(
      isSubmitting: false,
      error: AuthPhoneFormError.failed,
    );
    return false;
  }

  AuthPhoneFormError _mapFailureReason(PhoneAuthFailureReason? reason) {
    switch (reason) {
      case PhoneAuthFailureReason.invalidPhoneNumber:
        return AuthPhoneFormError.invalid;
      case PhoneAuthFailureReason.invalidCode:
        return AuthPhoneFormError.codeInvalid;
      case PhoneAuthFailureReason.expiredCode:
      case PhoneAuthFailureReason.sessionExpired:
        return AuthPhoneFormError.codeExpired;
      case PhoneAuthFailureReason.tooManyRequests:
        return AuthPhoneFormError.tooManyRequests;
      case PhoneAuthFailureReason.unknown:
      case null:
        return AuthPhoneFormError.failed;
    }
  }
}

AuthPhoneFormError? validatePhoneNumber(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return AuthPhoneFormError.empty;
  }

  final digitsOnly = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
  final hasInvalidPlusPlacement =
      trimmed.contains('+') && !trimmed.startsWith('+');
  if (hasInvalidPlusPlacement ||
      digitsOnly.length < 10 ||
      digitsOnly.length > 15) {
    return AuthPhoneFormError.invalid;
  }

  return null;
}

String normalizePhoneNumber(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return '';
  }

  final digitsOnly = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
  if (digitsOnly.isEmpty) {
    return '';
  }

  if (trimmed.startsWith('+')) {
    return '+$digitsOnly';
  }

  if (digitsOnly.startsWith('00') && digitsOnly.length > 2) {
    return '+${digitsOnly.substring(2)}';
  }

  return digitsOnly;
}

AuthPhoneFormError? validateSmsCode(String value) {
  final normalized = normalizeSmsCode(value);
  if (normalized.isEmpty) {
    return AuthPhoneFormError.codeEmpty;
  }

  if (normalized.length != 6) {
    return AuthPhoneFormError.codeInvalid;
  }

  return null;
}

String normalizeSmsCode(String value) {
  return value.trim().replaceAll(RegExp(r'[^0-9]'), '');
}

final authPhoneFormControllerProvider =
    NotifierProvider<AuthPhoneFormController, AuthPhoneFormState>(
  AuthPhoneFormController.new,
);
