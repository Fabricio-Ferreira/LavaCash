import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';

/// Placeholder when the user is operador and opens the Reports tab index.
class AccessDeniedReportsTab extends StatelessWidget {
  const AccessDeniedReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.lock_outline, size: 56, color: AppColors.outlineVariant),
          const SizedBox(height: 16),
          Text(
            'Acesso restrito',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Relatórios disponíveis apenas para administradores.',
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
