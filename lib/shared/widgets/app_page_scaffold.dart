import 'package:aktivite/app/theme/app_breakpoints.dart';
import 'package:aktivite/core/constants/app_spacing.dart';
import 'package:flutter/material.dart';

class AppPageScaffold extends StatelessWidget {
  const AppPageScaffold({
    required this.title,
    required this.child,
    this.actions,
    this.bottomNavigationBar,
    this.floatingActionButton,
    super.key,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        bottom: bottomNavigationBar == null,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final horizontalPadding =
                width >= AppBreakpoints.medium ? AppSpacing.xl : AppSpacing.md;

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppBreakpoints.contentMaxWidth,
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    AppSpacing.md,
                    horizontalPadding,
                    AppSpacing.xl,
                  ),
                  child: child,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
