import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/widgets/app_button.dart';
import '../../controllers/registration_controller.dart';

class RegistrationSubmitButton extends StatelessWidget {
  const RegistrationSubmitButton({super.key, required this.controller});

  final RegistrationController controller;

  static const double _horizontalPadding = 24;
  static const double _pillBorderRadius = 28;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          _horizontalPadding,
          8,
          _horizontalPadding,
          16,
        ),
        child: Obx(
          () => AppGradientButton(
            label: controller.isEditMode
                ? 'Salvar alterações'
                : 'Salvar e iniciar atendimento',
            isLoading: controller.isSaving.value,
            onPressed: controller.submit,
            trailingIcon: controller.isEditMode
                ? Icons.check_rounded
                : Icons.arrow_forward,
            borderRadius: _pillBorderRadius,
          ),
        ),
      ),
    );
  }
}
