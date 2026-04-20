import 'package:aktivite/app/app_routes.dart';
import 'package:aktivite/core/constants/app_spacing.dart';
import 'package:aktivite/core/utils/app_feedback.dart';
import 'package:aktivite/core/utils/analytics_events.dart';
import 'package:aktivite/features/auth/application/auth_phone_form_controller.dart';
import 'package:aktivite/features/auth/application/session_controller.dart';
import 'package:aktivite/l10n/app_localizations.dart';
import 'package:aktivite/core/config/repository_source.dart';
import 'package:aktivite/shared/providers/repository_providers.dart';
import 'package:aktivite/shared/widgets/app_section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthGateScreen extends ConsumerWidget {
  const AuthGateScreen({super.key});

  static const routePath = AppRoutes.auth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final authPhoneState = ref.watch(authPhoneFormControllerProvider);
    final repositorySource = ref.watch(repositorySourceProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.authTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          AppSectionCard(
            title: l10n.authTitle,
            subtitle: l10n.authSubtitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  initialValue: authPhoneState.phoneNumber,
                  onChanged: ref
                      .read(authPhoneFormControllerProvider.notifier)
                      .setPhoneNumber,
                  decoration: InputDecoration(
                    labelText: l10n.authPhoneFieldLabel,
                    hintText: l10n.authPhoneFieldHint,
                    helperText: l10n.authPhoneFieldHelper,
                    errorText: _errorTextFor(context, authPhoneState.error),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed: authPhoneState.canSubmit
                      ? () async {
                          await ref.read(analyticsServiceProvider).logEvent(
                                name: AnalyticsEvents.authPhoneSelected,
                              );
                          final success = await ref
                              .read(authPhoneFormControllerProvider.notifier)
                              .submit();
                          if (!context.mounted || success) {
                            return;
                          }
                          showAppSnackBar(
                            context,
                            _errorTextFor(
                                  context,
                                  ref
                                      .read(authPhoneFormControllerProvider)
                                      .error,
                                ) ??
                                l10n.authPhoneFailed,
                          );
                        }
                      : null,
                  child: Text(
                    authPhoneState.isSubmitting
                        ? l10n.authPhoneSubmitting
                        : l10n.continueWithPhone,
                  ),
                ),
                if (authPhoneState.pendingVerificationId != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  AppSectionCard(
                    title: l10n.authPhoneCodeSentTitle,
                    subtitle: l10n.authPhoneCodeSentMessage,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(l10n.authPhoneVerificationPending),
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.oneTimeCode],
                          initialValue: authPhoneState.smsCode,
                          onChanged: ref
                              .read(authPhoneFormControllerProvider.notifier)
                              .setSmsCode,
                          decoration: InputDecoration(
                            labelText: l10n.authCodeFieldLabel,
                            hintText: l10n.authCodeFieldHint,
                            errorText: _codeErrorTextFor(
                              context,
                              authPhoneState.error,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        FilledButton.tonal(
                          onPressed: authPhoneState.canSubmitCode
                              ? () async {
                                  final success = await ref
                                      .read(authPhoneFormControllerProvider
                                          .notifier)
                                      .submitCode();
                                  if (!context.mounted || success) {
                                    return;
                                  }
                                  showAppSnackBar(
                                    context,
                                    _codeErrorTextFor(
                                          context,
                                          ref
                                              .read(
                                                authPhoneFormControllerProvider,
                                              )
                                              .error,
                                        ) ??
                                        l10n.authPhoneFailed,
                                  );
                                }
                              : null,
                          child: Text(
                            authPhoneState.isSubmitting
                                ? l10n.authCodeSubmitting
                                : l10n.authCodeConfirm,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        TextButton(
                          onPressed: authPhoneState.canResendCode
                              ? () async {
                                  final success = await ref
                                      .read(authPhoneFormControllerProvider
                                          .notifier)
                                      .resendCode();
                                  if (!context.mounted || success) {
                                    return;
                                  }
                                  final currentState = ref.read(
                                    authPhoneFormControllerProvider,
                                  );
                                  showAppSnackBar(
                                    context,
                                    currentState.pendingVerificationId != null
                                        ? l10n.authCodeResent
                                        : _errorTextFor(
                                              context,
                                              currentState.error,
                                            ) ??
                                            l10n.authPhoneFailed,
                                  );
                                }
                              : null,
                          child: Text(l10n.authCodeResend),
                        ),
                      ],
                    ),
                  ),
                ],
                if (repositorySource == RepositorySource.inMemory) ...[
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton(
                    onPressed: () async {
                      await ref.read(analyticsServiceProvider).logEvent(
                            name: AnalyticsEvents.authGuestPreviewSelected,
                          );
                      await ref
                          .read(sessionControllerProvider.notifier)
                          .signInDemo();
                    },
                    child: Text(l10n.continueAsGuestPreview),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _errorTextFor(BuildContext context, AuthPhoneFormError? error) {
    final l10n = AppLocalizations.of(context);
    switch (error) {
      case AuthPhoneFormError.empty:
        return l10n.authPhoneEmpty;
      case AuthPhoneFormError.invalid:
        return l10n.authPhoneInvalid;
      case AuthPhoneFormError.codeEmpty:
      case AuthPhoneFormError.codeInvalid:
      case AuthPhoneFormError.codeExpired:
      case AuthPhoneFormError.tooManyRequests:
        return null;
      case AuthPhoneFormError.unsupported:
        return l10n.authPhoneUnsupported;
      case AuthPhoneFormError.failed:
        return l10n.authPhoneFailed;
      case null:
        return null;
    }
  }

  String? _codeErrorTextFor(BuildContext context, AuthPhoneFormError? error) {
    final l10n = AppLocalizations.of(context);
    switch (error) {
      case AuthPhoneFormError.codeEmpty:
        return l10n.authCodeEmpty;
      case AuthPhoneFormError.codeInvalid:
        return l10n.authCodeInvalid;
      case AuthPhoneFormError.codeExpired:
        return l10n.authCodeExpired;
      case AuthPhoneFormError.tooManyRequests:
        return l10n.authCodeTooManyRequests;
      case AuthPhoneFormError.failed:
        return l10n.authPhoneFailed;
      case AuthPhoneFormError.empty:
      case AuthPhoneFormError.invalid:
      case AuthPhoneFormError.unsupported:
      case null:
        return null;
    }
  }
}
