import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/payment_list_card.dart';
import '../models/daily_report_state.dart';

class DashboardRecebimentoSection extends StatelessWidget {
  const DashboardRecebimentoSection({super.key, required this.daily});

  final DailyReportState daily;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
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
        PaymentListCard(
          entries: daily.paymentEntries,
          isLoading: daily.isLoading,
        ),
      ],
    );
  }
}
