import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Title and short instructions for the waiting-for-invite screen.
class WaitingLinkageIntroSection extends StatelessWidget {
  const WaitingLinkageIntroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Icon(
          Icons.hourglass_top_rounded,
          size: 56,
          color: AppColors.primary.withValues(alpha: 0.85),
        ),
        const SizedBox(height: 20),
        Text(
          'Aguardando vinculação',
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Sua licença está ativa, mas este dispositivo ainda não foi '
          'vinculado à empresa. Envie o código abaixo ao administrador para '
          'ele cadastrar o convite.',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
