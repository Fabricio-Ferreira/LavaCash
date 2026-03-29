import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../core/utils/formatters.dart';

class PaymentEntryTile extends StatelessWidget {
  const PaymentEntryTile({super.key, required this.entry});

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
            children: <Widget>[
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
                  AppFormatters.iconForPaymentMethodKey(entry.key),
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  AppFormatters.labelForPaymentMethodKey(
                    entry.key,
                  ).toUpperCase(),
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
}
