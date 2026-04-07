import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lava_cash/core/utils/app_snackbar.dart';

import '../../../../app/theme/app_colors.dart';
import '../controllers/payment_controller.dart';
import 'widgets/payment_confirm_button.dart';
import 'widgets/payment_method_grid.dart';
import 'widgets/payment_service_details_card.dart';
import 'widgets/payment_total_value_section.dart';

class PaymentPage extends GetView<PaymentController> {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: <Widget>[
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: <Widget>[
              SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.surface,
                surfaceTintColor: Colors.transparent,
                title: Text(
                  'Finalizar Atendimento',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(<Widget>[
                    PaymentTotalValueSection(
                      valorController: controller.valorController,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Selecione o método de pagamento',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    PaymentMethodGrid(
                      selectedMethod: controller.selectedMethod,
                      onSelect: (m) {
                        controller.selectedMethod.value = m;
                      },
                    ),
                    const SizedBox(height: 24),
                    PaymentServiceDetailsCard(
                      nomeServico: controller.nomeServico,
                      placa: controller.placa,
                      horaEntrada: controller.horaEntrada,
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
                  ]),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Obx(
              () => PaymentConfirmButton(
                onPressed:
                    controller.selectedMethod.value != null
                        ? () => controller.submit()
                        : null,
                onDisabledPressed: () {
                  AppSnackbar.showError(
                    'Selecione um método de pagamento para '
                    'concluir o atendimento.',
                  );
                },
                isLoading: controller.isSaving,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
