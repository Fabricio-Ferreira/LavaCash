import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/formatters.dart';
import '../controllers/report_controller.dart';

class MonthlyReportTab extends GetView<ReportController> {
  const MonthlyReportTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Obx(
        () {
          if (controller.isMonthlyLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.monthlyReports.isEmpty) {
            return const Center(child: Text('Sem dados'));
          }
          return ListView.separated(
            itemCount: controller.monthlyReports.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (BuildContext context, int index) {
              final item = controller.monthlyReports[index];
              return Card(
                child: ListTile(
                  title: Text(
                    AppFormatters.formatMonthYear(item.mes),
                  ),
                  subtitle: Text('${item.totalAtendimentos} atendimentos'),
                  trailing: Text(
                    AppFormatters.formatCurrency(item.faturamento),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
