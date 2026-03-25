import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../models/daily_report_state.dart';

class DailyEliteHeroCard extends StatelessWidget {
  const DailyEliteHeroCard({super.key, required this.daily});

  final DailyReportState daily;

  @override
  Widget build(BuildContext context) {
    final String monthShort =
        DateFormat('MMM', 'pt_BR').format(DateTime.now()).toUpperCase();
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          right: -8,
          top: -28,
          child: Text(
            monthShort,
            style: TextStyle(
              fontSize: 88,
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
              colors: [
                Color(0xFF003816),
                Color(0xFF006E2F),
                AppColors.primary,
              ],
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
                      'TOTAL DO DIA',
                      style: TextStyle(
                        color: AppColors.primaryFixed.withValues(alpha: 0.85),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (daily.isLoading)
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
                      Text(
                        AppFormatters.formatCurrency(daily.totalRecebido),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                          letterSpacing: -1,
                        ),
                      ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.insights_outlined,
                            color: AppColors.primaryFixed.withValues(
                              alpha: 0.95,
                            ),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Comparativo vs. ontem em breve',
                            style: TextStyle(
                              color: AppColors.primaryFixed.withValues(
                                alpha: 0.9,
                              ),
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
            ],
          ),
        ),
      ],
    );
  }
}
