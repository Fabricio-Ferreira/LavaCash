import 'dart:ui';

import 'package:flutter/material.dart';

class MonthlyGrowthPill extends StatelessWidget {
  const MonthlyGrowthPill({super.key, required this.growthPercent});

  final double growthPercent;

  @override
  Widget build(BuildContext context) {
    final String pctText =
        growthPercent.abs() < 10 && growthPercent != 0
            ? growthPercent.toStringAsFixed(1)
            : growthPercent.round().toString();
    final String sign =
        growthPercent > 0
            ? '+'
            : growthPercent < 0
            ? ''
            : '';
    final String label = '$sign$pctText% vs mês anterior';
    final IconData icon =
        growthPercent > 0
            ? Icons.trending_up_rounded
            : growthPercent < 0
            ? Icons.trending_down_rounded
            : Icons.trending_flat_rounded;
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.55),
              width: 1,
            ),
            color: Colors.white.withValues(alpha: 0.18),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
