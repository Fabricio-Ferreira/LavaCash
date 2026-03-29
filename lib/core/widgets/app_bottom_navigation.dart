import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import 'nav_pill.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onSelect,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.paddingOf(context).bottom;
    const BorderRadius barBorderRadius = BorderRadius.vertical(
      top: Radius.circular(40),
    );
    return Container(
      decoration: BoxDecoration(
        borderRadius: barBorderRadius,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 18,
            spreadRadius: -1,
            offset: const Offset(0, -8),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 24,
            spreadRadius: -4,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: barBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, bottomInset + 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.94),
              border: Border(
                top: BorderSide(
                  color: AppColors.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                NavPill(
                  icon: Icons.bar_chart,
                  label: 'Relatórios',
                  selected: currentIndex == 1,
                  onTap: () => onSelect(1),
                ),
                NavPill(
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  selected: currentIndex == 0,
                  onTap: () => onSelect(0),
                ),
                NavPill(
                  icon: Icons.add_circle_outline,
                  label: 'Novo',
                  selected: false,
                  onTap: () => onSelect(2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
