import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import 'nav_pill.dart';

class StitchBottomNav extends StatelessWidget {
  const StitchBottomNav({
    super.key,
    required this.currentIndex,
    required this.onSelect,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final double bottom = MediaQuery.paddingOf(context).bottom;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, 12, 16, bottom + 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.94),
            border: Border(
              top: BorderSide(
                color: AppColors.outlineVariant.withValues(alpha: 0.35),
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 40,
                offset: const Offset(0, -12),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              NavPill(
                icon: Icons.receipt_long_outlined,
                label: 'Atividade',
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
    );
  }
}
