import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RouteActionButton extends StatelessWidget {
  const RouteActionButton({
    required this.label,
    required this.route,
    this.filled = false,
    this.tonal = true,
    super.key,
  });

  final String label;
  final String route;
  final bool filled;
  final bool tonal;

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return FilledButton.icon(
        onPressed: () => context.go(route),
        icon: const Icon(Icons.arrow_forward_rounded, size: 18),
        label: Text(label),
      );
    }

    if (tonal) {
      return FilledButton.tonalIcon(
        onPressed: () => context.go(route),
        icon: const Icon(Icons.arrow_forward_rounded, size: 18),
        label: Text(label),
      );
    }

    return OutlinedButton.icon(
      onPressed: () => context.go(route),
      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
      label: Text(label),
    );
  }
}
