import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import 'package:lava_cash/core/domain/entities/monthly_report.dart';
import '../monthly_growth_pill.dart';
import 'elite_hero_shell.dart';

class EliteHeroMonthlyCard extends StatelessWidget {
  const EliteHeroMonthlyCard({
    super.key,
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
    return EliteHeroShell(
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
                'Não houve movimentação neste mês. '
                'Quando houver atendimentos finalizados, o valor aparecerá aqui.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.92),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
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
