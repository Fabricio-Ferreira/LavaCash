import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/error/failures.dart';
import '../../../../domain/entities/payment_method.dart';
import '../../domain/usecases/complete_payment.dart';

class PaymentController extends GetxController {
  PaymentController({required CompletePayment completePayment})
      : _completePayment = completePayment;

  final CompletePayment _completePayment;

  final TextEditingController valorController = TextEditingController();
  final Rxn<PaymentMethod> selectedMethod = Rxn<PaymentMethod>();
  final RxBool isSaving = false.obs;
  final RxString errorMessage = ''.obs;

  String? get serviceId => Get.parameters['serviceId'];

  Future<void> submit() async {
    errorMessage.value = '';
    final String? id = serviceId;
    if (id == null) {
      errorMessage.value = 'Atendimento inválido.';
      return;
    }
    final double valor = _parseMoney(valorController.text);
    if (valor <= 0) {
      errorMessage.value = 'Informe um valor válido.';
      return;
    }
    final PaymentMethod? method = selectedMethod.value;
    if (method == null) {
      errorMessage.value = 'Selecione a forma de pagamento.';
      return;
    }
    isSaving.value = true;
    final Either<Failure, Unit> result = await _completePayment(
      serviceId: id,
      valor: valor,
      formaPagamento: method,
    );
    result.fold(
      (Failure failure) {
        errorMessage.value = failure.message;
      },
      (_) {
        Get.offAllNamed<void>(AppRoutes.home);
      },
    );
    isSaving.value = false;
  }

  double _parseMoney(String input) {
    final String trimmed = input.trim();
    if (trimmed.isEmpty) {
      return 0;
    }
    if (trimmed.contains(',')) {
      final String normalized =
          trimmed.replaceAll('.', '').replaceAll(',', '.');
      return double.tryParse(normalized) ?? 0;
    }
    return double.tryParse(trimmed) ?? 0;
  }

  @override
  void onClose() {
    valorController.dispose();
    super.onClose();
  }
}
