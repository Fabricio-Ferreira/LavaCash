import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import 'elite_hero_shell.dart';

class EliteHeroIntervalReportCard extends StatelessWidget {
  const EliteHeroIntervalReportCard({
    super.key,
    required this.isLoading,
    required this.totalRecebido,
  });

  final bool isLoading;
  final double totalRecebido;

  @override
  Widget build(BuildContext context) {
    final String monthWatermark =
        DateFormat('MMM', 'pt_BR').format(DateTime.now()).toUpperCase();
    return EliteHeroShell(
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
