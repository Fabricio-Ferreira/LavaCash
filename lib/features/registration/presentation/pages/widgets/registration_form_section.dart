import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/brazilian_phone_input_formatter.dart';
import '../../../../../core/utils/brazilian_plate_input_formatter.dart';
import '../../controllers/registration_controller.dart';
import 'registration_labeled_field.dart';

class RegistrationFormSection extends StatelessWidget {
  const RegistrationFormSection({super.key, required this.controller});

  final RegistrationController controller;

  static const double _horizontalPadding = 24;
  static const double _fieldSpacing = 16;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          RegistrationLabeledField(
            controller: controller.nomeController,
            labelUppercase: 'NOME COMPLETO',
            hint: 'Ex: João Silva',
            suffixIcon: Icons.person_outline_rounded,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: _fieldSpacing),
          RegistrationLabeledField(
            controller: controller.telefoneController,
            labelUppercase: 'TELEFONE',
            hint: '(00) 00000-0000',
            suffixIcon: Icons.call_outlined,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            inputFormatters: <TextInputFormatter>[
              BrazilianPhoneInputFormatter(),
            ],
          ),
          const SizedBox(height: _fieldSpacing),
          RegistrationLabeledField(
            controller: controller.placaController,
            labelUppercase: 'PLACA DO VEÍCULO',
            hint: 'ABC-1D23',
            suffixIcon: Icons.directions_car_outlined,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
            inputFormatters: <TextInputFormatter>[
              BrazilianPlateInputFormatter(),
            ],
          ),
          const SizedBox(height: 16),
          Obx(
            () => SelectableText.rich(
              TextSpan(
                text:
                    controller.errorMessage.value.isEmpty
                        ? ''
                        : controller.errorMessage.value,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
