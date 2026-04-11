import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/utils/formatters.dart';
import 'package:lava_cash/core/domain/entities/weekly_report.dart';

class WeeklyPerformanceSection extends StatefulWidget {
  const WeeklyPerformanceSection({
    super.key,
    required this.monthLabel,
    required this.weeklyData,
    required this.isLoading,
  });

  final String monthLabel;
  final List<WeeklyReport> weeklyData;
  final bool isLoading;

  @override
  State<WeeklyPerformanceSection> createState() =>
      _WeeklyPerformanceSectionState();
}

class _WeeklyPerformanceSectionState extends State<WeeklyPerformanceSection> {
  static const List<String> _weekLabels = <String>[
    'SEM 1',
    'SEM 2',
    'SEM 3',
    'SEM 4',
  ];

  late int _activeWeekIndex;

  @override
  void initState() {
    super.initState();
    _activeWeekIndex = _indexOfMaxWeekFaturamento(widget.weeklyData);
  }

  @override
  void didUpdateWidget(covariant WeeklyPerformanceSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_weeklySeriesEquals(oldWidget.weeklyData, widget.weeklyData)) {
      _activeWeekIndex = _indexOfMaxWeekFaturamento(widget.weeklyData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Desempenho Semanal',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              widget.monthLabel,
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.72),
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 168, child: _buildChartArea(textTheme)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List<Widget>.generate(_weekLabels.length, (int i) {
                    final bool isActive = i == _activeWeekIndex;
                    return Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _activeWeekIndex = i;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutCubic,
                            style: textTheme.labelMedium!.copyWith(
                              fontWeight:
                                  isActive ? FontWeight.w800 : FontWeight.w600,
                              color:
                                  isActive
                                      ? AppColors.primary
                                      : AppColors.onSurfaceVariant.withValues(
                                        alpha: 0.45,
                                      ),
                            ),
                            child: Text(
                              _weekLabels[i],
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChartArea(TextTheme textTheme) {
    if (widget.isLoading) {
      return const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (widget.weeklyData.length != 4) {
      return Center(
        child: Text(
          'Sem dados',
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.55),
          ),
        ),
      );
    }
    final List<WeeklyReport> series = widget.weeklyData;
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _weeklyChartMaxY(series),
        minY: 0,
        barGroups: List<BarChartGroupData>.generate(
          4,
          (int i) => BarChartGroupData(
            x: i,
            barRods: <BarChartRodData>[
              BarChartRodData(
                toY: series[i].faturamento,
                width: 18,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
                color:
                    i == _activeWeekIndex
                        ? AppColors.primary
                        : AppColors.outlineVariant.withValues(alpha: 0.4),
                fromY: 0,
              ),
            ],
          ),
        ),
        titlesData: const FlTitlesData(show: false),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          touchCallback: (FlTouchEvent event, BarTouchResponse? response) {
            if (!event.isInterestedForInteractions || response?.spot == null) {
              return;
            }
            setState(() {
              _activeWeekIndex = response!.spot!.touchedBarGroupIndex;
            });
          },
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.onSurface.withValues(alpha: 0.92),
            tooltipRoundedRadius: 8,
            getTooltipItem: (
              BarChartGroupData group,
              int groupIndex,
              BarChartRodData rod,
              int rodIndex,
            ) {
              if (groupIndex < 0 || groupIndex >= series.length) {
                return null;
              }
              return BarTooltipItem(
                AppFormatters.formatCurrency(series[groupIndex].faturamento),
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
      ),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }
}

double _weeklyChartMaxY(List<WeeklyReport> data) {
  double maxV = 0;
  for (final WeeklyReport w in data) {
    if (w.faturamento > maxV) {
      maxV = w.faturamento;
    }
  }
  if (maxV <= 0) {
    return 8;
  }
  return maxV * 1.15;
}

bool _weeklySeriesEquals(List<WeeklyReport> a, List<WeeklyReport> b) {
  if (a.length != b.length) {
    return false;
  }
  for (int i = 0; i < a.length; i++) {
    if (a[i].semana != b[i].semana || a[i].faturamento != b[i].faturamento) {
      return false;
    }
  }
  return true;
}

int _indexOfMaxWeekFaturamento(List<WeeklyReport> data) {
  if (data.isEmpty) {
    return 0;
  }
  int best = 0;
  double maxV = data.first.faturamento;
  for (int i = 1; i < data.length; i++) {
    if (data[i].faturamento > maxV) {
      maxV = data[i].faturamento;
      best = i;
    }
  }
  if (maxV <= 0 && data.length >= 4) {
    return 3;
  }
  return best;
}
