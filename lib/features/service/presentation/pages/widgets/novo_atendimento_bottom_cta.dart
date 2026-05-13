import 'package:flutter/material.dart';

import 'package:lava_cash/core/widgets/gradient_bottom_cta.dart';

class NovoAtendimentoBottomCta extends StatelessWidget {
  const NovoAtendimentoBottomCta({
    super.key,
    required this.isEnabled,
    required this.onPressed,
  });

  final bool isEnabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GradientBottomCta(
      isEnabled: isEnabled,
      onPressed: onPressed,
      icon: Icons.play_circle_filled,
      label: 'Iniciar atendimento',
    );
  }
}
