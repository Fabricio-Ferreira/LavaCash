import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../domain/entities/service_summary.dart';
import '../controllers/report_controller.dart';
import 'service_summary_tile.dart';

class DashboardAtendimentosSection extends StatelessWidget {
  const DashboardAtendimentosSection({
    super.key,
    required this.textTheme,
    required this.onVerTodos,
  });

  final TextTheme textTheme;
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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
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
                  children: [
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
              border: Border(
                left: BorderSide(color: AppColors.primary, width: 4),
              ),
            ),
            child: _buildBody(
              isLoading: isLoading,
              preview: preview,
              errorMessage: err,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildBody({
    required bool isLoading,
    required List<ServiceSummary> preview,
    required String errorMessage,
  }) {
    if (errorMessage.isNotEmpty && preview.isEmpty && !isLoading) {
      return SelectableText.rich(
        TextSpan(text: errorMessage, style: const TextStyle(color: Colors.red)),
      );
    }
    if (isLoading && preview.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (preview.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'Nenhum atendimento hoje.',
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      );
    }
    return Column(
      children: List<Widget>.generate(preview.length, (int i) {
        final Widget tile = ServiceSummaryTile(summary: preview[i]);
        if (i == preview.length - 1) {
          return tile;
        }
        return Column(
          children: [
            tile,
            Divider(
              height: 1,
              color: AppColors.outlineVariant.withValues(alpha: 0.5),
            ),
          ],
        );
      }),
    );
  }
}
