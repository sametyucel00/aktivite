import 'package:aktivite/l10n/app_localizations.dart';
import 'package:aktivite/shared/models/trust_signal.dart';
import 'package:flutter/material.dart';

class TrustSignalList extends StatelessWidget {
  const TrustSignalList({
    required this.signals,
    this.leading,
    super.key,
  });

  final List<TrustSignal> signals;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: signals
          .map(
            (signal) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: leading,
              title: Text(_signalLabel(l10n, signal.id)),
              subtitle: Text(_signalDescription(l10n, signal.id)),
            ),
          )
          .toList(growable: false),
    );
  }
}

String _signalLabel(AppLocalizations l10n, String id) {
  switch (id) {
    case 'approximateLocation':
      return l10n.trustApproximateLocationLabel;
    case 'approvalBeforeChat':
      return l10n.trustApprovalLabel;
    case 'safetyTools':
      return l10n.trustToolsLabel;
    default:
      return l10n.safetyTitle;
  }
}

String _signalDescription(AppLocalizations l10n, String id) {
  switch (id) {
    case 'approximateLocation':
      return l10n.trustApproximateLocationDescription;
    case 'approvalBeforeChat':
      return l10n.trustApprovalDescription;
    case 'safetyTools':
      return l10n.trustToolsDescription;
    default:
      return '';
  }
}
