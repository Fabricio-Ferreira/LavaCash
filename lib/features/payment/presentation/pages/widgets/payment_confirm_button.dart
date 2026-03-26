import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/widgets/app_button.dart';

class PaymentConfirmButton extends StatelessWidget {
  const PaymentConfirmButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
  });

  final VoidCallback? onPressed;
  final RxBool isLoading;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.6)),
          child: SafeArea(
            top: false,
            child: Obx(
              () => AppGradientButton(
                label: 'Concluir atendimento',
                trailingIcon: Icons.check,
                borderRadius: 24,
                height: 56,
                isLoading: isLoading.value,
                onPressed: onPressed,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
