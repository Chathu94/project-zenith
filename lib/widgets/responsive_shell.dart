import 'package:flutter/material.dart';

class ResponsiveShell extends StatelessWidget {
  const ResponsiveShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;
        final content = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: child,
        );

        if (!isWide) {
          return SafeArea(child: content);
        }

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: SafeArea(child: content),
            ),
          ),
        );
      },
    );
  }
}
