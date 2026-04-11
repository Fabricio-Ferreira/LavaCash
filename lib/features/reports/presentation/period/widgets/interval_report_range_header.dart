import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../controllers/interval_report_controller.dart';
import 'interval_report_date_range_field.dart';

class IntervalReportRangeHeader extends GetView<IntervalReportController> {
  const IntervalReportRangeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Obx(() {
      final DateTime start = controller.rangeStart.value;
      final DateTime end = controller.rangeEnd.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Período',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          IntervalReportDateRangeField(
            rangeStart: start,
            rangeEnd: end,
            onRangeConfirmed: controller.setRange,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  'Atalhos',
                  style: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              TextButton(
                onPressed: controller.applyLast7Days,
                child: const Text('7 dias'),
              ),
              TextButton(
                onPressed: controller.applyThisWeek,
                child: const Text('Esta semana'),
              ),
              TextButton(
                onPressed: controller.applyThisMonth,
                child: const Text('Este mês'),
              ),
            ],
          ),
        ],
      );
    });
  }
}
