import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class NavPill extends StatelessWidget {
  const NavPill({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.labelFontSize = 10,
    this.horizontalPadding = 18,
    this.iconSize = 26,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double labelFontSize;
  final double horizontalPadding;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    const Color activeNavColor = Color(0xFF10B981);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFECFDF5) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                size: iconSize,
                color: selected ? activeNavColor : AppColors.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: labelFontSize,
                  letterSpacing: 0.8,
                  color: selected ? activeNavColor : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
