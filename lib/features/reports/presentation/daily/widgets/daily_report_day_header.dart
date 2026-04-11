import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../controllers/report_controller.dart';

class DailyReportDayHeader extends GetView<ReportController> {
  const DailyReportDayHeader({super.key});

  Future<void> _pickDay(BuildContext context) async {
    final DateTime initial = controller.dailyReportDay.value;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) {
      controller.setDailyReportDay(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Obx(() {
      final DateTime day = controller.dailyReportDay.value;
      final String dayTitle =
          DateFormat("dd 'DE' MMMM", 'pt_BR').format(day).toUpperCase();
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
          const SizedBox(height: 8),
          Material(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => _pickDay(context),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        dayTitle,
                        style: textTheme.titleSmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.edit_calendar_outlined,
                      size: 24,
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
