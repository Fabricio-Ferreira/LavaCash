import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lava_cash/core/utils/app_snackbar.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../domain/entities/vehicle.dart';
import '../../domain/usecases/register_client_and_vehicle.dart';

class RegistrationController extends GetxController {
  RegistrationController({required RegisterClientAndVehicle register})
    : _register = register;

  final RegisterClientAndVehicle _register;

  final TextEditingController nomeController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();
  final TextEditingController placaController = TextEditingController();

  final RxBool isSaving = false.obs;
  final RxString errorMessage = ''.obs;

  Future<void> submit() async {
    errorMessage.value = '';
    final String nome = nomeController.text.trim();
    final String telefone = AppStringUtils.digitsOnly(telefoneController.text);
    final String placa = placaController.text.replaceAll("-", '');

    if (nome.isEmpty) {
      errorMessage.value = 'Informe o nome.';
      AppSnackbar.showError('Informe o nome.');
      return;
    }
    if (!AppValidators.isValidPhone(telefone)) {
      errorMessage.value = 'Telefone inválido.';
      AppSnackbar.showError('Telefone inválido.');
      return;
    }
    if (!AppValidators.isValidPlate(placa)) {
      errorMessage.value = 'Placa inválida.';
      AppSnackbar.showError('Placa inválida.');
      return;
    }
    isSaving.value = true;
    final Either<Failure, Vehicle> result = await _register(
      nome: nome,
      telefone: telefone,
      placa: placa,
    );
    result.fold(
      (Failure failure) {
        errorMessage.value = failure.message;
      },
      (Vehicle vehicle) {
        Get.offNamed<void>('${AppRoutes.service}/${vehicle.id}');
      },
    );
    isSaving.value = false;
  }

  @override
  void onClose() {
    nomeController.dispose();
    telefoneController.dispose();
    placaController.dispose();
    super.onClose();
  }
}
