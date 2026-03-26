import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';

class RegistrationInfoCard extends StatelessWidget {
  const RegistrationInfoCard({super.key});

  static const double _horizontalPadding = 24;
  static const double _verticalPadding = 16;
  static const double _borderRadius = 16;
  static const double _iconSize = 22;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _horizontalPadding,
        20,
        _horizontalPadding,
        0,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(_verticalPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Icon(
                Icons.info_outline_rounded,
                color: AppColors.primary,
                size: _iconSize,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Esses dados serão usados para agilizar os próximos '
                  'atendimentos e manter seu histórico de lavagens atualizado.',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
