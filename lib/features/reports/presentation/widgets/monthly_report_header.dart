import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../controllers/report_controller.dart';

class MonthlyReportHeader extends GetView<ReportController> {
  const MonthlyReportHeader({super.key});

  Future<void> _pickMonth(BuildContext context) async {
    final DateTime initial = controller.monthlyReportMonth.value;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
      helpText: 'Selecione um dia do mês',
    );
    if (picked != null) {
      controller.setMonthlyReportMonth(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Obx(() {
      final DateTime m = controller.monthlyReportMonth.value;
      final String monthYear = DateFormat(
        "MMMM yyyy",
        'pt_BR',
      ).format(m).toUpperCase();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Relatório mensal',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Material(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => _pickMonth(context),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        monthYear,
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.edit_calendar_outlined,
                      size: 18,
                      color: AppColors.outline,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
