import 'package:aktivite/core/constants/app_spacing.dart';
import 'package:flutter/material.dart';

class AppSectionCard extends StatelessWidget {
  const AppSectionCard({
    required this.title,
    required this.child,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
            ],
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}
