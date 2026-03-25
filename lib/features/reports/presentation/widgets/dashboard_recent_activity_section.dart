import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class DashboardRecentActivitySection extends StatelessWidget {
  const DashboardRecentActivitySection({
    super.key,
    required this.textTheme,
    required this.onVerTudo,
  });

  final TextTheme textTheme;
  final VoidCallback onVerTudo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Atividade Recente',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            TextButton(onPressed: onVerTudo, child: const Text('VER TUDO')),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border(
              left: BorderSide(color: AppColors.primary, width: 4),
            ),
          ),
          child: Text(
            'Em Relatórios › Diário, toque em VER TODOS para buscar veículos, '
            'ou use Novo na barra inferior.',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
