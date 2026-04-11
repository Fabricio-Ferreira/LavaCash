import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/themed_refresh_indicator.dart';
import 'package:lava_cash/core/domain/entities/best_weekday_report.dart';
import 'package:lava_cash/core/domain/entities/monthly_report.dart';
import 'package:lava_cash/core/domain/entities/weekly_report.dart';
import '../../../../shared/widgets/dashboard_stats/dashboard_stat_card.dart';
import '../../../../shared/widgets/dashboard_stats/dashboard_stat_grid.dart';
import '../../../../shared/widgets/elite_hero_card.dart';
import '../controllers/report_controller.dart';
import 'utils/monthly_report_growth.dart';
import 'widgets/monthly_best_weekday_card.dart';
import 'widgets/monthly_list_card.dart';
import 'widgets/monthly_report_header.dart';
import 'widgets/weekly_performance_section.dart';

/// Stitch-style monthly reports (hero + stats + month cards).
class MonthlyReportTab extends GetView<ReportController> {
  const MonthlyReportTab({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Obx(() {
      final bool isMonthlyLoading = controller.isMonthlyLoading.value;
      final String errorMessage = controller.errorMessage.value;
      final List<MonthlyReport> monthlyList =
          controller.monthlyReports.toList();
      final DateTime selectedMonth = controller.monthlyReportMonth.value;
      final List<WeeklyReport> weeklyList = controller.weeklyReports.toList();
      final bool isWeeklyLoading = controller.isWeeklyLoading.value;
      final BestWeekdayReport? bestWeekdayReport =
          controller.bestWeekday.value;
      final MonthlyReport? highlight = ReportController.resolveMonthInList(
        monthlyList,
        selectedMonth,
      );
      final double? growthPct = computeGrowthPercentVsPreviousMonth(
        monthlyList,
        highlight,
      );
      final int totalMeses = monthlyList.length;
      return ThemedRefreshIndicator(
        onRefresh: () async {
          await controller.loadMonthly();
          await controller.loadWeekly(controller.monthlyReportMonth.value);
        },
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints c) {
            final double pad = c.maxWidth > 600 ? 24 : 16;
            if (isMonthlyLoading) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.fromLTRB(pad, 8, pad, 120),
                children: const [
                  SizedBox(
                    height: 240,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              );
            }
            if (errorMessage.isNotEmpty && monthlyList.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.fromLTRB(pad, 8, pad, 120),
                children: [
                  SelectableText.rich(
                    TextSpan(
                      text: errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              );
            }
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(pad, 8, pad, 120),
              children: [
                const MonthlyReportHeader(),
                const SizedBox(height: 16),
                EliteHeroCard.monthly(
                  highlight: highlight,
                  growthPercentVsPrevious: growthPct,
                ),
                const SizedBox(height: 16),
                DashboardStatGrid(
                  children: <Widget>[
                    DashboardStatCard(
                      icon: Icons.local_car_wash_outlined,
                      iconColor: AppColors.primary,
                      label: 'ATENDIMENTOS',
                      value:
                          highlight == null
                              ? '0'
                              : '${highlight.totalAtendimentos}',
                    ),
                    DashboardStatCard(
                      icon: Icons.calendar_month_outlined,
                      iconColor: AppColors.primary,
                      label: 'MESES REGISTRADOS',
                      value: '$totalMeses',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                WeeklyPerformanceSection(
                  key: ValueKey<String>(
                    '${selectedMonth.year}-${selectedMonth.month}',
                  ),
                  monthLabel: DateFormat(
                    'MMMM',
                    'pt_BR',
                  ).format(selectedMonth).toUpperCase(),
                  weeklyData: weeklyList,
                  isLoading: isWeeklyLoading,
                ),
                const SizedBox(height: 12),
                MonthlyBestWeekdayCard(
                  isLoading: isWeeklyLoading,
                  report: bestWeekdayReport,
                ),
                const SizedBox(height: 24),
                Text(
                  'Histórico por mês',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                if (monthlyList.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      'Sem dados',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  ...monthlyList.map(
                    (MonthlyReport item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: MonthlyListCard(item: item),
                    ),
                  ),
              ],
            );
          },
        ),
      );
    });
  }
}
