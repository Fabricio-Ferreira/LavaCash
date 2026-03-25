import 'package:flutter/material.dart';

/// [RefreshIndicator] using [ThemeData.colorScheme] (primary + surface).
class ThemedRefreshIndicator extends StatelessWidget {
  const ThemedRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.displacement = 40,
  });

  final Future<void> Function() onRefresh;
  final Widget child;
  final double displacement;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return RefreshIndicator(
      color: scheme.primary,
      backgroundColor: scheme.surface,
      displacement: displacement,
      onRefresh: onRefresh,
      child: child,
    );
  }
}
