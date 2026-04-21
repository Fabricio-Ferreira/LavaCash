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
    return ThemedRefreshIndicator(
      onRefresh: () async {
        await controller.loadMonthly();
        await controller.loadWeekly(controller.monthlyReportMonth.value);
      },
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints c) {
          final double pad = c.maxWidth > 600 ? 24 : 16;
          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: <Widget>[
              _MonthlyLoadingSliver(horizontalPadding: pad),
              _MonthlyErrorSliver(horizontalPadding: pad),
              _MonthlyHeroAndStatsSliver(
                horizontalPadding: pad,
                textTheme: textTheme,
              ),
              _MonthlyWeeklyBlockSliver(horizontalPadding: pad),
              _MonthlyHistorySliver(
                horizontalPadding: pad,
                bottomPadding: 120,
                textTheme: textTheme,
              ),
            ],
          );
        },
      ),
    );
  }
}

bool _monthlyBodyVisible(ReportController c) {
  if (c.isMonthlyLoading.value) {
    return false;
  }
  final String err = c.errorMessage.value;
  final List<MonthlyReport> list = c.monthlyReports.toList();
  if (err.isNotEmpty && list.isEmpty) {
    return false;
  }
  return true;
}

class _MonthlyLoadingSliver extends GetView<ReportController> {
  const _MonthlyLoadingSliver({required this.horizontalPadding});

  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isMonthlyLoading.value) {
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      }
      return SliverPadding(
        padding: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 120),
        sliver: const SliverToBoxAdapter(
          child: SizedBox(
            height: 240,
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      );
    });
  }
}

class _MonthlyErrorSliver extends GetView<ReportController> {
  const _MonthlyErrorSliver({required this.horizontalPadding});

  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final String err = controller.errorMessage.value;
      final bool loading = controller.isMonthlyLoading.value;
      final List<MonthlyReport> list = controller.monthlyReports.toList();
      if (err.isEmpty || loading || list.isNotEmpty) {
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      }
      return SliverPadding(
        padding: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 120),
        sliver: SliverToBoxAdapter(
          child: SelectableText.rich(
            TextSpan(
              text: err,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      );
    });
  }
}

/// Hero + grid: só reage a dados mensais (não a weekly isolado).
class _MonthlyHeroAndStatsSliver extends GetView<ReportController> {
  const _MonthlyHeroAndStatsSliver({
    required this.horizontalPadding,
    required this.textTheme,
  });

  final double horizontalPadding;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!_monthlyBodyVisible(controller)) {
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      }
      final List<MonthlyReport> monthlyList =
          controller.monthlyReports.toList();
      final DateTime selectedMonth = controller.monthlyReportMonth.value;
      final MonthlyReport? highlight = ReportController.resolveMonthInList(
        monthlyList,
        selectedMonth,
      );
      final double? growthPct = computeGrowthPercentVsPreviousMonth(
        monthlyList,
        highlight,
      );
      final int totalMeses = monthlyList.length;
      return SliverPadding(
        padding: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 0),
        sliver: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
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
                    value: highlight == null
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
            ],
          ),
        ),
      );
    });
  }
}

/// Gráfico semanal + melhor dia: reage a weekly / bestWeekday sem reconstruir hero.
class _MonthlyWeeklyBlockSliver extends GetView<ReportController> {
  const _MonthlyWeeklyBlockSliver({required this.horizontalPadding});

  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!_monthlyBodyVisible(controller)) {
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      }
      final DateTime selectedMonth = controller.monthlyReportMonth.value;
      final List<WeeklyReport> weeklyList = controller.weeklyReports.toList();
      final bool isWeeklyLoading = controller.isWeeklyLoading.value;
      final BestWeekdayReport? bestWeekdayReport =
          controller.bestWeekday.value;
      return SliverPadding(
        padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 0),
        sliver: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
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
            ],
          ),
        ),
      );
    });
  }
}

class _MonthlyHistorySliver extends GetView<ReportController> {
  const _MonthlyHistorySliver({
    required this.horizontalPadding,
    required this.bottomPadding,
    required this.textTheme,
  });

  final double horizontalPadding;
  final double bottomPadding;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!_monthlyBodyVisible(controller)) {
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      }
      final List<MonthlyReport> monthlyList =
          controller.monthlyReports.toList();
      if (monthlyList.isEmpty) {
        return SliverPadding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            24,
            horizontalPadding,
            bottomPadding,
          ),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Histórico por mês',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    'Sem dados',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      final int childCount = 1 + monthlyList.length;
      return SliverPadding(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          24,
          horizontalPadding,
          bottomPadding,
        ),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              if (index == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'Histórico por mês',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              }
              final MonthlyReport item = monthlyList[index - 1];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: MonthlyListCard(item: item),
              );
            },
            childCount: childCount,
          ),
        ),
      );
    });
  }
}
