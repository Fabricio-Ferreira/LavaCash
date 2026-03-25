import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class DailyAttendimentosPlaceholder extends StatelessWidget {
  const DailyAttendimentosPlaceholder({super.key, required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border(left: BorderSide(color: AppColors.primary, width: 4)),
      ),
      child: Text(
        'Lista detalhada de atendimentos será exibida quando os dados '
        'estiverem disponíveis. Use VER TODOS para buscar veículos.',
        style: textTheme.bodyMedium?.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}
