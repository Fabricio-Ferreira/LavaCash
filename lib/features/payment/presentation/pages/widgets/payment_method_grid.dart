import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lava_cash/core/domain/entities/payment_method.dart';
import 'payment_method_card.dart';

const List<PaymentMethod> kPaymentGridOrder = <PaymentMethod>[
  PaymentMethod.pix,
  PaymentMethod.dinheiro,
  PaymentMethod.debito,
  PaymentMethod.credito,
];

class PaymentMethodGrid extends StatelessWidget {
  const PaymentMethodGrid({
    super.key,
    required this.selectedMethod,
    required this.onSelect,
  });

  final Rxn<PaymentMethod> selectedMethod;
  final void Function(PaymentMethod) onSelect;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.15,
        children:
            kPaymentGridOrder.map((PaymentMethod m) {
              final bool selected = selectedMethod.value == m;
              return PaymentMethodCard(
                method: m,
                selected: selected,
                onTap: () => onSelect(m),
              );
            }).toList(),
      ),
    );
  }
}
