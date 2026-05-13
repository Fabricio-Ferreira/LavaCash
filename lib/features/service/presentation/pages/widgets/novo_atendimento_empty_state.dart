import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';

class NovoAtendimentoEmptyState extends StatelessWidget {
  const NovoAtendimentoEmptyState({super.key, required this.onRegisterTap});

  final VoidCallback onRegisterTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_search,
              size: 40,
              color: AppColors.outline,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum cliente encontrado',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
