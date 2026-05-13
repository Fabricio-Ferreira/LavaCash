import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lava_cash/core/utils/app_snackbar.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/brazilian_phone_input_formatter.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../../core/utils/validators.dart';
import 'package:lava_cash/core/domain/entities/client.dart';
import 'package:lava_cash/core/domain/entities/vehicle.dart';
import 'package:lava_cash/core/domain/entities/vehicle_with_client.dart';
import 'package:lava_cash/core/domain/registration/usecases/register_client_and_vehicle.dart';
import 'package:lava_cash/core/domain/registration/usecases/update_client_and_vehicle.dart';

class RegistrationController extends GetxController {
  RegistrationController({
    required RegisterClientAndVehicle register,
    required UpdateClientAndVehicle updateClientAndVehicle,
  }) : _register = register,
       _updateClientAndVehicle = updateClientAndVehicle;

  final RegisterClientAndVehicle _register;
  final UpdateClientAndVehicle _updateClientAndVehicle;

  final TextEditingController nomeController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();
  final TextEditingController placaController = TextEditingController();

  VehicleWithClient? _editInitial;

  bool get isEditMode => _editInitial != null;

  final RxBool isSaving = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final dynamic raw = Get.arguments;
    if (raw is VehicleWithClient) {
      _editInitial = raw;
      nomeController.text = raw.client.nome;
      telefoneController.text = BrazilianPhoneInputFormatter.maskedFromStored(
        raw.client.telefone,
      );
      placaController.text = AppFormatters.formatPlate(raw.vehicle.placa);
    }
  }

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
    if (_editInitial != null) {
      final Either<Failure, Vehicle> result = await _updateClientAndVehicle(
        clienteId: _editInitial!.client.id,
        veiculoId: _editInitial!.vehicle.id,
        nome: nome,
        telefone: telefone,
        placa: placa,
      );
      result.fold(
        (Failure failure) {
          errorMessage.value = failure.message;
          isSaving.value = false;
        },
        (Vehicle vehicle) {
          final Client clientResolved = vehicle.client ?? _editInitial!.client;
          final VehicleWithClient payload = VehicleWithClient(
            vehicle: vehicle,
            client: clientResolved,
          );

          WidgetsBinding.instance.addPostFrameCallback((_) {
            AppSnackbar.showSuccess('Cliente atualizado.');
          });
          Get.back<VehicleWithClient>(result: payload);
        },
      );
      return;
    }
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
