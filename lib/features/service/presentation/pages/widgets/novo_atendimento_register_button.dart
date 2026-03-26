import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';

class NovoAtendimentoRegisterButton extends StatelessWidget {
  const NovoAtendimentoRegisterButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          backgroundColor: AppColors.primary.withValues(alpha: 0.05),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text(
          'Cadastrar novo cliente',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
