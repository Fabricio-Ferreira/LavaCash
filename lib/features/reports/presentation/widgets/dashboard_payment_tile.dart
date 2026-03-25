import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';

class DashboardPaymentTile extends StatelessWidget {
  const DashboardPaymentTile({
    super.key,
    required this.entry,
  });

  final MapEntry<String, double> entry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.12),
                  ),
                ),
                child: Icon(
                  DashboardPaymentTile.iconForPayment(entry.key),
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  DashboardPaymentTile.labelForPayment(entry.key).toUpperCase(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Text(
                AppFormatters.formatCurrency(entry.value),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData iconForPayment(String raw) {
    final String k = raw.toLowerCase();
    if (k.contains('pix')) {
      return Icons.qr_code_2;
    }
    if (k.contains('dinheiro') || k.contains('espécie')) {
      return Icons.payments_outlined;
    }
    if (k.contains('débito') || k.contains('debito')) {
      return Icons.credit_card;
    }
    if (k.contains('crédito') || k.contains('credito')) {
      return Icons.credit_score;
    }
    return Icons.payment;
  }

  static String labelForPayment(String raw) {
    return raw.replaceAll('_', ' ');
  }
}
