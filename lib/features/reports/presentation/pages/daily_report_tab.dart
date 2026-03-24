import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/formatters.dart';
import '../controllers/report_controller.dart';

class DailyReportTab extends GetView<ReportController> {
  const DailyReportTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Obx(
        () {
          if (controller.isDailyLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          final report = controller.dailyReport.value;
          if (report == null) {
            return const Center(child: Text('Sem dados'));
          }
          return ListView(
            children: [
              Text(
                'Hoje',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _SummaryCard(
                label: 'Carros lavados',
                value: '${report.totalCarros}',
              ),
              const SizedBox(height: 12),
              _SummaryCard(
                label: 'Total recebido',
                value: AppFormatters.formatCurrency(report.totalRecebido),
              ),
              const SizedBox(height: 24),
              Text(
                'Por forma de pagamento',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              ...report.totalPorFormaPagamento.entries.map(
                (MapEntry<String, double> e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    child: ListTile(
                      title: Text(e.key),
                      trailing: Text(
                        AppFormatters.formatCurrency(e.value),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
