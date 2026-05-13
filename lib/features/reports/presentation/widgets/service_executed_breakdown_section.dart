import 'package:flutter/material.dart';
import 'package:lava_cash/app/theme/app_colors.dart';
import 'package:lava_cash/core/domain/entities/service_breakdown_row.dart';
import 'package:lava_cash/core/utils/formatters.dart';

/// Header + stacked cards for “Serviços executados” (daily / monthly reports).
class ServiceExecutedBreakdownSection extends StatelessWidget {
  const ServiceExecutedBreakdownSection({
    super.key,
    required this.sectionTitle,
    required this.sectionSubtitle,
    required this.errorText,
    required this.rows,
    required this.textTheme,
    required this.isContentHidden,
    required this.statusLabel,
    required this.iconForDisplayName,
  });

  final String sectionTitle;
  final String sectionSubtitle;
  final String errorText;
  final List<ServiceBreakdownRow> rows;
  final TextTheme textTheme;
  final bool isContentHidden;
  final String statusLabel;
  final IconData Function(String nomeExibicao) iconForDisplayName;

  @override
  Widget build(BuildContext context) {
    if (isContentHidden) {
      return const SizedBox.shrink();
    }
    if (errorText.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: SelectableText.rich(
          TextSpan(text: errorText, style: const TextStyle(color: Colors.red)),
        ),
      );
    }
    if (rows.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          sectionTitle,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          sectionSubtitle,
          style: textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF757575),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        ...<Widget>[
          for (int i = 0; i < rows.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(height: 12),
            _ServiceExecutedBreakdownCard(
              row: rows[i],
              textTheme: textTheme,
              statusLabel: statusLabel,
              iconData: iconForDisplayName(rows[i].nomeExibicao),
            ),
          ],
        ],
      ],
    );
  }
}

class _ServiceExecutedBreakdownCard extends StatelessWidget {
  const _ServiceExecutedBreakdownCard({
    required this.row,
    required this.textTheme,
    required this.statusLabel,
    required this.iconData,
  });

  final ServiceBreakdownRow row;
  final TextTheme textTheme;
  final String statusLabel;
  final IconData iconData;

  static const Color _badgeBackground = Color(0xFFE8F5E9);
  static const Color _iconBackdrop = Color(0xFFF5F5F5);
  static const Color _muted = Color(0xFF757575);

  @override
  Widget build(BuildContext context) {
    final BrlCurrencyStackParts parts = AppFormatters.currencyStackParts(
      row.faturamento,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(22),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _iconBackdrop,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    row.nomeExibicao,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    children: <Widget>[
                      Text(
                        'QTD: ${row.quantidade}',
                        style: textTheme.bodySmall?.copyWith(
                          color: _muted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '•',
                        style: textTheme.bodySmall?.copyWith(color: _muted),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _badgeBackground,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          statusLabel,
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  parts.symbolText,
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  parts.amountText,
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
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
