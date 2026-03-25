import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../models/daily_report_state.dart';
import 'dashboard_payment_tile.dart';

class DashboardRecebimentoSection extends StatelessWidget {
  const DashboardRecebimentoSection({
    super.key,
    required this.daily,
    required this.textTheme,
  });

  final DailyReportState daily;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recebimento',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'HOJE',
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  fontSize: 10,
                  color: AppColors.onSurfaceVariant,
                ),
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
              color: AppColors.outlineVariant.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child:
              daily.isLoading
                  ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : daily.paymentEntries.isEmpty
                  ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Nenhum recebimento hoje',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  )
                  : Column(
                    children:
                        daily.paymentEntries
                            .map(
                              (MapEntry<String, double> e) =>
                                  DashboardPaymentTile(entry: e),
                            )
                            .toList(),
                  ),
        ),
      ],
    );
  }
}
