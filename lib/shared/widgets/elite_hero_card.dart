import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/monthly_report.dart';
import 'monthly_growth_pill.dart';

/// Green gradient hero card shared by dashboard, daily report, and monthly report.
abstract class EliteHeroCard extends StatelessWidget {
  const EliteHeroCard({super.key});

  factory EliteHeroCard.dashboard({
    required bool isLoading,
    required double totalRecebido,
    required double totalDespesas,
  }) {
    return _EliteHeroDashboardCard(
      isLoading: isLoading,
      totalRecebido: totalRecebido,
      totalDespesas: totalDespesas,
    );
  }

  factory EliteHeroCard.dailyReport({
    required bool isLoading,
    required double totalRecebido,
    required double totalDespesas,
  }) {
    return _EliteHeroDailyReportCard(
      isLoading: isLoading,
      totalRecebido: totalRecebido,
      totalDespesas: totalDespesas,
    );
  }

  factory EliteHeroCard.intervalReport({
    required bool isLoading,
    required double totalRecebido,
  }) {
    return _EliteHeroIntervalReportCard(
      isLoading: isLoading,
      totalRecebido: totalRecebido,
    );
  }

  factory EliteHeroCard.monthly({
    required MonthlyReport? highlight,
    double? growthPercentVsPrevious,
  }) {
    return _EliteHeroMonthlyCard(
      highlight: highlight,
      growthPercentVsPrevious: growthPercentVsPrevious,
    );
  }

  static const double _borderRadius = 24;
  static const List<Color> _gradientColors = <Color>[
    Color(0xFF003816),
    Color(0xFF006E2F),
    AppColors.primary,
  ];

  static Widget _shell({
    required Widget child,
    String? watermarkText,
    double watermarkFontSize = 88,
    double watermarkRight = -8,
    double watermarkTop = -28,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        if (watermarkText != null)
          Positioned(
            right: watermarkRight,
            top: watermarkTop,
            child: Text(
              watermarkText,
              style: TextStyle(
                fontSize: watermarkFontSize,
                fontWeight: FontWeight.w900,
                height: 1,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_borderRadius),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: _gradientColors,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.28),
                blurRadius: 36,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(_borderRadius),
                    gradient: RadialGradient(
                      center: Alignment.topLeft,
                      radius: 1.2,
                      colors: <Color>[
                        Colors.white.withValues(alpha: 0.18),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              child,
            ],
          ),
        ),
      ],
    );
  }
}

/// Shared layout: saldo = recebido − despesas, then breakdown rows.
class _EliteHeroDailyBalanceBlock extends StatelessWidget {
  const _EliteHeroDailyBalanceBlock({
    required this.isLoading,
    required this.totalRecebido,
    required this.totalDespesas,
    required this.mainSaldoFontSize,
    this.crossAlignStart = false,
  });

  final bool isLoading;
  final double totalRecebido;
  final double totalDespesas;
  final double mainSaldoFontSize;
  final bool crossAlignStart;

  @override
  Widget build(BuildContext context) {
    final double saldoDoDia = totalRecebido - totalDespesas;
    final TextStyle rowLabelStyle = TextStyle(
      color: AppColors.primaryFixed.withValues(alpha: 0.82),
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
    );
    final TextStyle recebidoValueStyle = TextStyle(
      color: AppColors.primaryFixed.withValues(alpha: 0.98),
      fontSize: 15,
      fontWeight: FontWeight.w800,
    );
    final TextStyle expenseLabelStyle = rowLabelStyle.copyWith(
      color: AppColors.surface,
    );
    final TextStyle expenseValueStyle = TextStyle(
      color: AppColors.expenseRed,
      fontSize: 15,
      fontWeight: FontWeight.w800,
    );
    final Color saldoColor =
        saldoDoDia < 0 ? AppColors.expenseRed : Colors.white;
    return Column(
      crossAxisAlignment:
          crossAlignStart
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.stretch,
      children: <Widget>[
        if (isLoading)
          SizedBox(
            height: mainSaldoFontSize + 8,
            child: const Align(
              alignment: Alignment.centerLeft,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          )
        else ...<Widget>[
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                AppFormatters.formatCurrency(saldoDoDia),
                maxLines: 1,
                style: TextStyle(
                  color: saldoColor,
                  fontSize: mainSaldoFontSize,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                  letterSpacing: -1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _HeroMoneyRow(
            label: 'Valores recebidos',
            valueText: AppFormatters.formatCurrency(totalRecebido),
            labelStyle: rowLabelStyle.copyWith(color: AppColors.surface),
            valueStyle: recebidoValueStyle,
          ),
          const SizedBox(height: 8),
          _HeroMoneyRow(
            label: 'Despesas do dia',
            valueText: AppFormatters.formatCurrencyExpenseOutflow(
              totalDespesas,
            ),
            labelStyle: expenseLabelStyle,
            valueStyle: expenseValueStyle,
          ),
        ],
      ],
    );
  }
}

class _HeroMoneyRow extends StatelessWidget {
  const _HeroMoneyRow({
    required this.label,
    required this.valueText,
    required this.labelStyle,
    required this.valueStyle,
  });

  final String label;
  final String valueText;
  final TextStyle labelStyle;
  final TextStyle valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: Text(label, style: labelStyle)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(valueText, textAlign: TextAlign.right, style: valueStyle),
        ),
      ],
    );
  }
}

class _EliteHeroDashboardCard extends EliteHeroCard {
  const _EliteHeroDashboardCard({
    required this.isLoading,
    required this.totalRecebido,
    required this.totalDespesas,
  });

  final bool isLoading;
  final double totalRecebido;
  final double totalDespesas;

  @override
  Widget build(BuildContext context) {
    final String monthWatermark =
        DateFormat('MMM', 'pt_BR').format(DateTime.now()).toUpperCase();
    return EliteHeroCard._shell(
      watermarkText: monthWatermark,
      watermarkFontSize: 96,
      watermarkTop: -32,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'TOTAL DO DIA',
                  style: TextStyle(
                    color: AppColors.primaryFixed.withValues(alpha: 0.85),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
                Icon(
                  Icons.water_drop_outlined,
                  color: AppColors.primaryFixed.withValues(alpha: 0.55),
                  size: 22,
                ),
              ],
            ),
            const SizedBox(height: 10),
            _EliteHeroDailyBalanceBlock(
              isLoading: isLoading,
              totalRecebido: totalRecebido,
              totalDespesas: totalDespesas,
              mainSaldoFontSize: 40,
              crossAlignStart: true,
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixed.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'ATUALIZADO AGORA',
                  style: TextStyle(
                    color: AppColors.primaryFixed.withValues(alpha: 0.72),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EliteHeroDailyReportCard extends EliteHeroCard {
  const _EliteHeroDailyReportCard({
    required this.isLoading,
    required this.totalRecebido,
    required this.totalDespesas,
  });

  final bool isLoading;
  final double totalRecebido;
  final double totalDespesas;

  @override
  Widget build(BuildContext context) {
    final String monthWatermark =
        DateFormat('MMM', 'pt_BR').format(DateTime.now()).toUpperCase();
    return EliteHeroCard._shell(
      watermarkText: monthWatermark,
      watermarkFontSize: 88,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'TOTAL DO DIA',
              style: TextStyle(
                color: AppColors.primaryFixed.withValues(alpha: 0.85),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            _EliteHeroDailyBalanceBlock(
              isLoading: isLoading,
              totalRecebido: totalRecebido,
              totalDespesas: totalDespesas,
              mainSaldoFontSize: 34,
              crossAlignStart: false,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.insights_outlined,
                    color: AppColors.primaryFixed.withValues(alpha: 0.95),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Comparativo vs. ontem em breve',
                    style: TextStyle(
                      color: AppColors.primaryFixed.withValues(alpha: 0.9),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EliteHeroIntervalReportCard extends EliteHeroCard {
  const _EliteHeroIntervalReportCard({
    required this.isLoading,
    required this.totalRecebido,
  });

  final bool isLoading;
  final double totalRecebido;

  @override
  Widget build(BuildContext context) {
    final String monthWatermark =
        DateFormat('MMM', 'pt_BR').format(DateTime.now()).toUpperCase();
    return EliteHeroCard._shell(
      watermarkText: monthWatermark,
      watermarkFontSize: 88,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'TOTAL NO PERÍODO',
              style: TextStyle(
                color: AppColors.primaryFixed.withValues(alpha: 0.85),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            if (isLoading)
              const SizedBox(
                height: 48,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppFormatters.formatCurrency(totalRecebido),
                    maxLines: 1,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                      letterSpacing: -1,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.date_range_outlined,
                    color: AppColors.primaryFixed.withValues(alpha: 0.95),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Entradas de lavagens finalizadas',
                    style: TextStyle(
                      color: AppColors.primaryFixed.withValues(alpha: 0.9),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EliteHeroMonthlyCard extends EliteHeroCard {
  const _EliteHeroMonthlyCard({
    required this.highlight,
    this.growthPercentVsPrevious,
  });

  final MonthlyReport? highlight;
  final double? growthPercentVsPrevious;

  @override
  Widget build(BuildContext context) {
    final MonthlyReport? report = highlight;
    final String? watermarkText =
        report == null
            ? null
            : DateFormat('MMM', 'pt_BR').format(report.mes).toUpperCase();
    return EliteHeroCard._shell(
      watermarkText: watermarkText,
      watermarkFontSize: 72,
      watermarkRight: -4,
      watermarkTop: -24,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'FATURAMENTO DO MÊS',
              style: TextStyle(
                color: AppColors.primaryFixed.withValues(alpha: 0.85),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            if (report == null)
              Text(
                '—',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppFormatters.formatCurrency(report.faturamento),
                    maxLines: 1,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                      letterSpacing: -1,
                    ),
                  ),
                ),
              ),
            if (report != null) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                AppFormatters.formatMonthYear(report.mes).toUpperCase(),
                style: TextStyle(
                  color: AppColors.primaryFixed.withValues(alpha: 0.82),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            if (growthPercentVsPrevious != null) ...<Widget>[
              const SizedBox(height: 16),
              MonthlyGrowthPill(growthPercent: growthPercentVsPrevious!),
            ],
          ],
        ),
      ),
    );
  }
}
