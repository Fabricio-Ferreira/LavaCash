import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import 'package:lava_cash/core/domain/entities/service_summary.dart';
import 'package:lava_cash/features/reports/presentation/controllers/report_controller.dart';
import 'dashboard_atendimentos_preview_body.dart';

class DashboardAtendimentosSection extends StatelessWidget {
  const DashboardAtendimentosSection({
    super.key,
    required this.onVerTodos,
  });

  final VoidCallback onVerTodos;

  static const int _previewCount = 3;

  @override
  Widget build(BuildContext context) {
    final ReportController reports = Get.find<ReportController>();
    return Obx(() {
      final bool isLoading = reports.isTodayServicesLoading.value;
      final List<ServiceSummary> preview = reports.todayServices
          .take(_previewCount)
          .toList(growable: false);
      final String err = reports.todayServicesError.value;
      final TextTheme textTheme = Theme.of(context).textTheme;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Atendimentos do dia',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton(
                onPressed: onVerTodos,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('VER TODOS'),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
              border: const Border(
                left: BorderSide(color: AppColors.primary, width: 4),
              ),
            ),
            child: DashboardAtendimentosPreviewBody(
              textTheme: textTheme,
              isLoading: isLoading,
              preview: preview,
              errorMessage: err,
            ),
          ),
        ],
      );
    });
  }
}
