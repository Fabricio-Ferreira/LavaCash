import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import 'elite_hero_daily_balance_block.dart';
import 'elite_hero_shell.dart';

class EliteHeroDailyReportCard extends StatelessWidget {
  const EliteHeroDailyReportCard({
    super.key,
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
    return EliteHeroShell(
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
            EliteHeroDailyBalanceBlock(
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
