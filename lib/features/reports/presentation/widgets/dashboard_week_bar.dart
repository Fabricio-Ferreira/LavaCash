import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class DashboardWeekBar extends StatelessWidget {
  const DashboardWeekBar({
    super.key,
    required this.heightFactor,
    required this.highlight,
    required this.label,
    required this.showAtual,
  });

  final double heightFactor;
  final bool highlight;
  final String label;
  final bool showAtual;

  @override
  Widget build(BuildContext context) {
    final Color fill = highlight
        ? const Color(0xFF10B981)
        : AppColors.primary.withValues(alpha: 0.35);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (showAtual)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              'ATUAL',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF10B981),
                  ),
            ),
          ),
        Expanded(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints c) {
              final double fullH = c.maxHeight;
              final double barH = fullH * heightFactor;
              return Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    width: double.infinity,
                    height: fullH,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: barH,
                    decoration: BoxDecoration(
                      color: fill,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                      boxShadow: highlight
                          ? [
                              BoxShadow(
                                color: const Color(0xFF10B981)
                                    .withValues(alpha: 0.45),
                                blurRadius: 16,
                                offset: const Offset(0, -4),
                              ),
                            ]
                          : null,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 9,
                fontWeight: highlight ? FontWeight.w900 : FontWeight.w700,
                color: highlight
                    ? const Color(0xFF10B981)
                    : AppColors.onSurfaceVariant.withValues(alpha: 0.45),
              ),
        ),
      ],
    );
  }
}
