import 'package:aktivite/features/activities/application/join_request_composer_controller.dart';
import 'package:aktivite/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const controller = JoinRequestComposerController();
  final l10n = AppLocalizationsEn();

  group('JoinRequestComposerController', () {
    test('presetMessages returns unique localized presets', () {
      final presets = controller.presetMessages(l10n);

      expect(presets, isNotEmpty);
      expect(presets.first, l10n.joinRequestDefaultMessage);
      expect(presets, contains(l10n.joinRequestPresetNearby));
      expect(presets, contains(l10n.joinRequestPresetTimeFit));
      expect(presets, contains(l10n.joinRequestPresetFlexible));
      expect(presets.toSet().length, presets.length);
    });

    test('normalizeMessage trims whitespace', () {
      expect(controller.normalizeMessage('  hello there  '), 'hello there');
      expect(controller.normalizeMessage(null), isEmpty);
    });

    test('isValid requires non-empty normalized content', () {
      expect(controller.isValid('   '), isFalse);
      expect(controller.isValid(' Ready to join '), isTrue);
    });

    test('isDefaultMessage compares normalized values', () {
      expect(
        controller.isDefaultMessage(
          l10n,
          '  ${l10n.joinRequestDefaultMessage}  ',
        ),
        isTrue,
      );
      expect(controller.isDefaultMessage(l10n, l10n.joinRequestPresetNearby),
          isFalse);
    });
  });
}
