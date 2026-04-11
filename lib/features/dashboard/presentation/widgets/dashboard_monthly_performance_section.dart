import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import 'package:lava_cash/core/domain/entities/monthly_report.dart';
import 'package:lava_cash/features/reports/presentation/controllers/report_controller.dart';
import 'dashboard_week_bar.dart';

String _monthlyTotalLabel(List<MonthlyReport> last6) {
  if (last6.isEmpty) {
    return AppFormatters.formatCurrency(0);
  }
  final MonthlyReport latest = last6.last;
  return AppFormatters.formatCurrency(latest.faturamento);
}

double? _monthlyPercentVersusPrevious(List<MonthlyReport> sortedDesc) {
  if (sortedDesc.length < 2) {
    return null;
  }
  final double cur = sortedDesc[0].faturamento;
  final double prev = sortedDesc[1].faturamento;
  if (prev == 0) {
    return null;
  }
  return ((cur - prev) / prev) * 100;
}

class DashboardMonthlyPerformanceSection extends StatelessWidget {
  const DashboardMonthlyPerformanceSection({
    super.key,
    required this.reports,
    required this.onOpenMonthly,
  });

  final ReportController reports;
  final VoidCallback onOpenMonthly;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Obx(() {
      if (reports.isMonthlyLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ),
        );
      }
      final List<MonthlyReport> list = reports.monthlyReports.toList();
      final List<MonthlyReport> last6 =
          list.length > 6 ? list.sublist(0, 6) : List<MonthlyReport>.from(list);
      last6.sort((MonthlyReport a, MonthlyReport b) => a.mes.compareTo(b.mes));
      final double maxFat =
          last6.isEmpty
              ? 1
              : last6
                  .map((MonthlyReport m) => m.faturamento)
                  .reduce((double a, double b) => a > b ? a : b);
      final double? pct = _monthlyPercentVersusPrevious(list);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Desempenho Mensal',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (pct != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Text(
                    '${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(0)}% vs mês anterior',
                    style: textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF16A34A),
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            elevation: 2,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: onOpenMonthly,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FATURAMENTO TOTAL',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        fontSize: 10,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _monthlyTotalLabel(last6),
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 108,
                      child:
                          last6.isEmpty
                              ? Center(
                                child: Text(
                                  'Sem dados mensais',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              )
                              : Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: List<Widget>.generate(last6.length, (
                                  int i,
                                ) {
                                  final MonthlyReport m = last6[i];
                                  final double h =
                                      maxFat > 0
                                          ? (m.faturamento / maxFat)
                                              .clamp(0.08, 1.0)
                                              .toDouble()
                                          : 0.1;
                                  final bool isLast = i == last6.length - 1;
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 3,
                                      ),
                                      child: DashboardWeekBar(
                                        heightFactor: h,
                                        highlight: isLast,
                                        label: 'S${i + 1}',
                                        showAtual: isLast,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: onOpenMonthly,
                        child: const Text('Ver relatório mensal'),
                      ),
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
