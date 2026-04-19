import 'package:aktivite/core/constants/app_spacing.dart';
import 'package:aktivite/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

Future<String?> showJoinRequestDialog(
  BuildContext context, {
  required AppLocalizations l10n,
  required String initialMessage,
  required List<String> presetMessages,
  required bool Function(String? value) isValid,
}) async {
  final controller = TextEditingController(text: initialMessage);

  try {
    return await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(l10n.joinRequestDialogTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.joinRequestDialogHint),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.joinRequestPresetTitle,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: presetMessages
                      .map(
                        (preset) => ActionChip(
                          label: Text(preset),
                          onPressed: () {
                            controller.value = TextEditingValue(
                              text: preset,
                              selection: TextSelection.collapsed(
                                offset: preset.length,
                              ),
                            );
                            setState(() {});
                          },
                        ),
                      )
                      .toList(growable: false),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: controller,
                  minLines: 2,
                  maxLines: 4,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: l10n.joinRequestFieldLabel,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.commonCancel),
              ),
              FilledButton(
                onPressed: isValid(controller.text)
                    ? () => Navigator.of(context).pop(controller.text)
                    : null,
                child: Text(l10n.joinRequestSend),
              ),
            ],
          ),
        );
      },
    );
  } finally {
    controller.dispose();
  }
}
