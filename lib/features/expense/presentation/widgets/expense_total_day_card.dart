import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';

class ExpenseTotalDayCard extends StatelessWidget {
  const ExpenseTotalDayCard({super.key, required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.tertiary.withValues(alpha: 0.08),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Total do dia',
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            Text(
              AppFormatters.formatCurrency(total),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.tertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
