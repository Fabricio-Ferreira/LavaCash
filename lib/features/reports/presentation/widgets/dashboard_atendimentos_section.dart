import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../domain/entities/service_summary.dart';
import '../controllers/report_controller.dart';
import 'service_summary_tile.dart';

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
            child: _AtendimentosBody(
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

class _AtendimentosBody extends StatelessWidget {
  const _AtendimentosBody({
    required this.textTheme,
    required this.isLoading,
    required this.preview,
    required this.errorMessage,
  });

  final TextTheme textTheme;
  final bool isLoading;
  final List<ServiceSummary> preview;
  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    if (errorMessage.isNotEmpty && preview.isEmpty && !isLoading) {
      return SelectableText.rich(
        TextSpan(
          text: errorMessage,
          style: const TextStyle(color: Colors.red),
        ),
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
      children: List<Widget>.generate(preview.length, (int index) {
        final Widget tile = ServiceSummaryTile(summary: preview[index]);
        if (index == preview.length - 1) {
          return tile;
        }
        return Column(
          children: <Widget>[
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
