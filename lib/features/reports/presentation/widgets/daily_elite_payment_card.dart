import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import 'dashboard_payment_tile.dart';

class DailyElitePaymentCard extends StatelessWidget {
  const DailyElitePaymentCard({
    super.key,
    required this.entries,
    required this.isLoading,
  });

  final List<MapEntry<String, double>> entries;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: isLoading
          ? const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          : entries.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Nenhum recebimento hoje',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                  ),
                )
              : Column(
                  children: entries
                      .map(
                        (MapEntry<String, double> e) => DashboardPaymentTile(
                          entry: e,
                        ),
                      )
                      .toList(),
                ),
    );
  }
}
