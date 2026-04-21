import 'package:aktivite/core/constants/app_spacing.dart';
import 'package:aktivite/shared/widgets/app_surface.dart';
import 'package:flutter/material.dart';

class AsyncLoadingView extends StatelessWidget {
  const AsyncLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppSurface(
      tonal: true,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class AsyncErrorView extends StatelessWidget {
  const AsyncErrorView({
    required this.message,
    super.key,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      tonal: true,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}
