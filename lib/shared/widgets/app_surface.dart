import 'package:aktivite/app/theme/app_radii.dart';
import 'package:aktivite/app/theme/app_shadows.dart';
import 'package:aktivite/core/constants/app_spacing.dart';
import 'package:flutter/material.dart';

class AppSurface extends StatelessWidget {
  const AppSurface({
    required this.child,
    this.padding,
    this.tonal = false,
    this.alignment,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool tonal;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final backgroundColor =
        tonal ? scheme.surfaceContainerHigh : scheme.surface;

    return Container(
      width: double.infinity,
      alignment: alignment,
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.7)),
        boxShadow: AppShadows.soft(scheme.shadow),
      ),
      child: child,
    );
  }
}
