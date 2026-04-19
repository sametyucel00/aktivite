import 'package:aktivite/features/activities/data/join_request_repository.dart';
import 'package:aktivite/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class JoinRequestComposerController {
  const JoinRequestComposerController();

  String initialMessage(AppLocalizations l10n) {
    return l10n.joinRequestDefaultMessage;
  }

  List<String> presetMessages(AppLocalizations l10n) {
    return {
      initialMessage(l10n),
      l10n.joinRequestPresetNearby,
      l10n.joinRequestPresetTimeFit,
      l10n.joinRequestPresetFlexible,
    }.toList(growable: false);
  }

  String normalizeMessage(String? value) {
    return value?.trim() ?? '';
  }

  bool isValid(String? value) {
    return normalizeMessage(value).isNotEmpty;
  }

  bool isDefaultMessage(AppLocalizations l10n, String? value) {
    return normalizeMessage(value) == normalizeMessage(initialMessage(l10n));
  }

  Future<void> submit({
    required JoinRequestRepository repository,
    required String activityId,
    required String message,
  }) {
    return repository.submitJoinRequest(
      activityId: activityId,
      message: normalizeMessage(message),
    );
  }
}

final joinRequestComposerControllerProvider =
    Provider<JoinRequestComposerController>(
  (ref) => const JoinRequestComposerController(),
);
