import 'package:aktivite/app/app_routes.dart';
import 'package:flutter/foundation.dart';
import 'package:aktivite/core/constants/app_spacing.dart';
import 'package:aktivite/core/utils/app_feedback.dart';
import 'package:aktivite/core/utils/analytics_events.dart';
import 'package:aktivite/features/auth/application/auth_phone_form_controller.dart';
import 'package:aktivite/features/auth/application/session_controller.dart';
import 'package:aktivite/l10n/app_localizations.dart';
import 'package:aktivite/core/config/repository_source.dart';
import 'package:aktivite/shared/providers/repository_providers.dart';
import 'package:aktivite/shared/widgets/app_section_card.dart';
import 'package:aktivite/shared/widgets/app_page_scaffold.dart';
import 'package:aktivite/shared/widgets/app_section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthGateScreen extends ConsumerStatefulWidget {
  const AuthGateScreen({super.key});

  static const routePath = AppRoutes.auth;

  @override
  ConsumerState<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends ConsumerState<AuthGateScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _isSubmittingEmail = false;
  bool _isSubmittingProvider = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authPhoneState = ref.watch(authPhoneFormControllerProvider);
    final repositorySource = ref.watch(repositorySourceProvider);
    const supportsPhoneAuth = !kIsWeb;
    final supportsGoogle = kIsWeb ||
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
    final supportsApple = kIsWeb || defaultTargetPlatform == TargetPlatform.iOS;
    return AppPageScaffold(
      title: l10n.authTitle,
      child: ListView(
        children: [
          AppSectionHeader(
            title: l10n.authTitle,
            subtitle: l10n.authSubtitle,
            centered: true,
          ),
          const SizedBox(height: AppSpacing.md),
          AppSectionCard(
            title: l10n.authTitle,
            subtitle: l10n.authSubtitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (supportsPhoneAuth) ...[
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
                  Center(
                    child: FilledButton(
                      onPressed: authPhoneState.canSubmit
                          ? () async {
                              await ref.read(analyticsServiceProvider).logEvent(
                                    name: AnalyticsEvents.authPhoneSelected,
                                  );
                              final success = await ref
                                  .read(
                                      authPhoneFormControllerProvider.notifier)
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
                  ),
                ] else
                  Text(
                    l10n.authPhoneUnsupported,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                if (supportsPhoneAuth &&
                    authPhoneState.pendingVerificationId != null) ...[
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
          const SizedBox(height: AppSpacing.md),
          AppSectionCard(
            title: l10n.authOtherMethodsTitle,
            subtitle: l10n.authOtherMethodsSubtitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: InputDecoration(
                    labelText: l10n.authEmailFieldLabel,
                    hintText: l10n.authEmailFieldHint,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  decoration: InputDecoration(
                    labelText: l10n.authPasswordFieldLabel,
                    helperText: l10n.authPasswordFieldHelper,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: FilledButton.icon(
                    onPressed: _isSubmittingEmail
                        ? null
                        : () => _submitEmailSignIn(context),
                    icon: _isSubmittingEmail
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.mail_outline),
                    label: Text(l10n.continueWithEmail),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  alignment: WrapAlignment.center,
                  children: [
                    if (supportsGoogle)
                      OutlinedButton.icon(
                        onPressed: _isSubmittingProvider
                            ? null
                            : () => _submitProviderSignIn(
                                  context,
                                  provider: _AuthProvider.google,
                                ),
                        icon: const Icon(Icons.g_mobiledata_outlined),
                        label: Text(l10n.continueWithGoogle),
                      ),
                    if (supportsApple)
                      OutlinedButton.icon(
                        onPressed: _isSubmittingProvider
                            ? null
                            : () => _submitProviderSignIn(
                                  context,
                                  provider: _AuthProvider.apple,
                                ),
                        icon: const Icon(Icons.apple),
                        label: Text(l10n.continueWithApple),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitEmailSignIn(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (!email.contains('@') || password.length < 6) {
      showAppSnackBar(context, l10n.authEmailInvalid);
      return;
    }

    setState(() {
      _isSubmittingEmail = true;
    });
    try {
      final result =
          await ref.read(sessionControllerProvider.notifier).signInWithEmail(
                email: email,
                password: password,
              );
      if (!context.mounted || result.isSignedIn) {
        return;
      }
      showAppSnackBar(context, l10n.authEmailFailed);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingEmail = false;
        });
      }
    }
  }

  Future<void> _submitProviderSignIn(
    BuildContext context, {
    required _AuthProvider provider,
  }) async {
    setState(() {
      _isSubmittingProvider = true;
    });
    try {
      final controller = ref.read(sessionControllerProvider.notifier);
      final result = switch (provider) {
        _AuthProvider.google => await controller.signInWithGoogle(),
        _AuthProvider.apple => await controller.signInWithApple(),
      };
      if (!context.mounted || result.isSignedIn) {
        return;
      }
      showAppSnackBar(context, AppLocalizations.of(context).authProviderFailed);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingProvider = false;
        });
      }
    }
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

enum _AuthProvider { google, apple }
