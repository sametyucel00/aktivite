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
      return FilledButton(
        onPressed: () => context.go(route),
        child: Text(label),
      );
    }

    if (tonal) {
      return FilledButton.tonal(
        onPressed: () => context.go(route),
        child: Text(label),
      );
    }

    return OutlinedButton(
      onPressed: () => context.go(route),
      child: Text(label),
    );
  }
}
