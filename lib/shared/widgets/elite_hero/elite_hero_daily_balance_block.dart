import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import 'hero_money_row.dart';

/// Saldo = recebido − despesas, then breakdown rows.
class EliteHeroDailyBalanceBlock extends StatelessWidget {
  const EliteHeroDailyBalanceBlock({
    super.key,
    required this.isLoading,
    required this.totalRecebido,
    required this.totalDespesas,
    required this.mainSaldoFontSize,
    this.crossAlignStart = false,
  });

  final bool isLoading;
  final double totalRecebido;
  final double totalDespesas;
  final double mainSaldoFontSize;
  final bool crossAlignStart;

  @override
  Widget build(BuildContext context) {
    final double saldoDoDia = totalRecebido - totalDespesas;
    final TextStyle rowLabelStyle = TextStyle(
      color: AppColors.primaryFixed.withValues(alpha: 0.82),
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
    );
    final TextStyle recebidoValueStyle = TextStyle(
      color: AppColors.primaryFixed.withValues(alpha: 0.98),
      fontSize: 15,
      fontWeight: FontWeight.w800,
    );
    final TextStyle expenseLabelStyle = rowLabelStyle.copyWith(
      color: AppColors.surface,
    );
    final TextStyle expenseValueStyle = TextStyle(
      color: AppColors.expenseRed,
      fontSize: 15,
      fontWeight: FontWeight.w800,
    );
    final Color saldoColor =
        saldoDoDia < 0 ? AppColors.expenseRed : Colors.white;
    return Column(
      crossAxisAlignment:
          crossAlignStart
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.stretch,
      children: <Widget>[
        if (isLoading)
          SizedBox(
            height: mainSaldoFontSize + 8,
            child: const Align(
              alignment: Alignment.centerLeft,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          )
        else ...<Widget>[
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                AppFormatters.formatCurrency(saldoDoDia),
                maxLines: 1,
                style: TextStyle(
                  color: saldoColor,
                  fontSize: mainSaldoFontSize,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                  letterSpacing: -1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          HeroMoneyRow(
            label: 'Valores recebidos',
            valueText: AppFormatters.formatCurrency(totalRecebido),
            labelStyle: rowLabelStyle.copyWith(color: AppColors.surface),
            valueStyle: recebidoValueStyle,
          ),
          const SizedBox(height: 8),
          HeroMoneyRow(
            label: 'Despesas do dia',
            valueText: AppFormatters.formatCurrencyExpenseOutflow(
              totalDespesas,
            ),
            labelStyle: expenseLabelStyle,
            valueStyle: expenseValueStyle,
          ),
        ],
      ],
    );
  }
}
