import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../domain/entities/payment_method.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/payment_controller.dart';

class PaymentPage extends GetView<PaymentController> {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pagamento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: controller.valorController,
              label: 'Valor (R\$)',
              hint: '0,00',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Forma de pagamento',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    PaymentMethod.values.map((PaymentMethod method) {
                      final bool selected =
                          controller.selectedMethod.value == method;
                      return ChoiceChip(
                        label: Text(method.label),
                        selected: selected,
                        onSelected: (_) {
                          controller.selectedMethod.value = method;
                        },
                      );
                    }).toList(),
              ),
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
                label: 'Concluir atendimento',
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
