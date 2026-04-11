import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import 'elite_hero_daily_balance_block.dart';
import 'elite_hero_shell.dart';

class EliteHeroDashboardCard extends StatelessWidget {
  const EliteHeroDashboardCard({
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
            EliteHeroDailyBalanceBlock(
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
