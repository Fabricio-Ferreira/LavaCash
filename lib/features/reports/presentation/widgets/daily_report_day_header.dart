import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';

class DailyReportDayHeader extends StatelessWidget {
  const DailyReportDayHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final DateTime now = DateTime.now();
    final String dayTitle =
        DateFormat("dd 'DE' MMMM", 'pt_BR').format(now).toUpperCase();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Relatório do dia',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          dayTitle,
          style: textTheme.labelSmall?.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}
