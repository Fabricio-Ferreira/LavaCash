import 'package:flutter/material.dart';

/// Two-column grid for dashboard stat cards (same pattern as
/// [PaymentMethodGrid]).
class DashboardStatGrid extends StatelessWidget {
  const DashboardStatGrid({
    super.key,
    required this.children,
    this.crossAxisSpacing = 12,
    this.mainAxisSpacing = 12,
    this.childAspectRatio = 1.18,
  });

  final List<Widget> children;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: childAspectRatio,
      children: children,
    );
  }
}
