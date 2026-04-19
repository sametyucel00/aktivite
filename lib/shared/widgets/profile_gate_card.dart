import 'package:aktivite/l10n/app_localizations.dart';
import 'package:aktivite/shared/widgets/app_section_card.dart';
import 'package:aktivite/shared/widgets/route_action_button.dart';
import 'package:flutter/material.dart';

class ProfileGateCard extends StatelessWidget {
  const ProfileGateCard({
    required this.completion,
    required this.profileRoute,
    super.key,
  });

  final int completion;
  final String profileRoute;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppSectionCard(
      title: l10n.profileGateTitle,
      subtitle: l10n.profileGateMessage(completion),
      child: Align(
        alignment: Alignment.centerLeft,
        child: RouteActionButton(
          label: l10n.profileGateAction,
          route: profileRoute,
          filled: true,
        ),
      ),
    );
  }
}
