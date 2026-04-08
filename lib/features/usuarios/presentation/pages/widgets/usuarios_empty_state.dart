import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';

class UsuariosEmptyState extends StatelessWidget {
  const UsuariosEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.group_outlined,
            size: 64,
            color: AppColors.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum usuário cadastrado',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Use o botão abaixo para convidar um dispositivo.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.outlineVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
