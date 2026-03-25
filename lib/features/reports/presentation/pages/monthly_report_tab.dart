import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/themed_refresh_indicator.dart';
import '../controllers/report_controller.dart';

class MonthlyReportTab extends GetView<ReportController> {
  const MonthlyReportTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ThemedRefreshIndicator(
        onRefresh: () async {
          await controller.loadMonthly();
        },
        child: Obx(
          () {
            if (controller.isMonthlyLoading.value) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(
                    height: 240,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              );
            }
            if (controller.monthlyReports.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(
                    height: 200,
                    child: Center(child: Text('Sem dados')),
                  ),
                ],
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
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
      ),
    );
  }
}
