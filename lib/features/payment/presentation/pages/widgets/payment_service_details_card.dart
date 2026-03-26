import 'package:flutter/material.dart';
import 'package:lava_cash/core/utils/string_utils.dart';

import '../../../../../app/theme/app_colors.dart';
import 'payment_detail_row.dart';

class PaymentServiceDetailsCard extends StatelessWidget {
  const PaymentServiceDetailsCard({
    super.key,
    required this.nomeServico,
    required this.placa,
    required this.horaEntrada,
  });

  final String? nomeServico;
  final String? placa;
  final DateTime? horaEntrada;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            PaymentDetailRow(
              label: 'Serviço',
              value: AppStringUtils.formatNomeServico(nomeServico),
            ),
            const SizedBox(height: 16),
            PaymentDetailRow(
              label: 'Veículo',
              value: AppStringUtils.formatVeiculo(placa),
            ),
            const SizedBox(height: 16),
            PaymentDetailRow(
              label: 'Data',
              value: AppStringUtils.formatDataHora(horaEntrada),
            ),
          ],
        ),
      ),
    );
  }
}
