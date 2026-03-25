import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/entities/monthly_report.dart';
import 'monthly_growth_pill.dart';

class MonthlyEliteHeroCard extends StatelessWidget {
  const MonthlyEliteHeroCard({
    super.key,
    required this.highlight,
    this.growthPercentVsPrevious,
  });

  final MonthlyReport? highlight;
  final double? growthPercentVsPrevious;

  @override
  Widget build(BuildContext context) {
    final MonthlyReport? report = highlight;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (report != null)
          Positioned(
            right: -4,
            top: -24,
            child: Text(
              DateFormat('MMM', 'pt_BR').format(report.mes).toUpperCase(),
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.w900,
                height: 1,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF003816), Color(0xFF006E2F), AppColors.primary],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.28),
                blurRadius: 36,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: RadialGradient(
                      center: Alignment.topLeft,
                      radius: 1.2,
                      colors: [
                        Colors.white.withValues(alpha: 0.18),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                      Text(
                        AppFormatters.formatCurrency(report.faturamento),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                          letterSpacing: -1,
                        ),
                      ),
                    if (report != null) ...[
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
                    if (growthPercentVsPrevious != null) ...[
                      const SizedBox(height: 16),
                      MonthlyGrowthPill(
                        growthPercent: growthPercentVsPrevious!,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
