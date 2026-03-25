import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/registration_controller.dart';

class RegistrationPage extends GetView<RegistrationController> {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo cadastro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: controller.nomeController,
              label: 'Nome',
              hint: 'Nome completo',
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: controller.telefoneController,
              label: 'Telefone',
              hint: '(11) 99999-9999',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: controller.placaController,
              label: 'Placa',
              hint: 'ABC1D23',
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 24),
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
            const SizedBox(height: 8),
            Obx(
              () => AppButton(
                label: 'Salvar',
                isLoading: controller.isSaving.value,
                onPressed: controller.submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
