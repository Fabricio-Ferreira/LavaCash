import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({
    super.key,
    required this.onNovoAtendimento,
    required this.onRelatorioDiario,
    required this.onRelatorioPeriodo,
    required this.onDespesas,
  });

  final VoidCallback onNovoAtendimento;
  final VoidCallback onRelatorioDiario;
  final VoidCallback onRelatorioPeriodo;
  final VoidCallback onDespesas;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryContainer],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.22),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onNovoAtendimento,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Novo atendimento',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 10),
            side: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.22),
              width: 2,
            ),
            backgroundColor: AppColors.primary.withValues(alpha: 0.05),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: onRelatorioDiario,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart),
              SizedBox(width: 8),
              Text(
                'Relatório diário',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 10),
            side: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.22),
              width: 2,
            ),
            backgroundColor: AppColors.primary.withValues(alpha: 0.05),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: onRelatorioPeriodo,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.date_range),
              SizedBox(width: 8),
              Text(
                'Relatório por período',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.tertiary,
            padding: const EdgeInsets.symmetric(vertical: 10),
            side: BorderSide(
              color: AppColors.tertiary.withValues(alpha: 0.35),
              width: 2,
            ),
            backgroundColor: AppColors.tertiary.withValues(alpha: 0.06),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: onDespesas,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long),
              SizedBox(width: 8),
              Text(
                'Despesas do dia',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
