import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/whatsapp_service.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/entities/service_record.dart';
import '../../../../domain/entities/service_status.dart';
import '../../../../domain/entities/vehicle_with_client.dart';
import '../../../reports/presentation/controllers/report_controller.dart';
import '../../domain/repositories/service_repository.dart';
import '../../domain/usecases/start_service.dart';

class ServiceController extends GetxController {
  ServiceController({
    required ServiceRepository repository,
    required StartService startService,
  }) : _repository = repository,
       _startService = startService;

  final ServiceRepository _repository;
  final StartService _startService;

  final Rxn<VehicleWithClient> vehicle = Rxn<VehicleWithClient>();
  final Rxn<ServiceRecord> serviceRecord = Rxn<ServiceRecord>();
  final RxInt elapsedSeconds = 0.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isAddingDetails = false.obs;
  final RxBool paymentFormValid = false.obs;

  final TextEditingController nomeServicoController = TextEditingController();
  final TextEditingController valorController = TextEditingController();
  final TextEditingController observacaoController = TextEditingController();

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    nomeServicoController.addListener(_syncPaymentFormValidity);
    valorController.addListener(_syncPaymentFormValidity);
    bootstrap();
  }

  void _syncPaymentFormValidity() {
    final bool hasNome = nomeServicoController.text.trim().isNotEmpty;
    final double? valor = AppFormatters.parseMoneyInput(valorController.text);
    paymentFormValid.value =
        hasNome && valor != null && valor > 0;
  }

  void _syncFormFromRecord(ServiceRecord record) {
    nomeServicoController.text = record.nomeServico ?? '';
    observacaoController.text = record.observacao ?? '';
    if (record.valor != null) {
      valorController.text = _formatValorForField(record.valor!);
    } else {
      valorController.clear();
    }
    _syncPaymentFormValidity();
  }

  String _formatValorForField(double value) {
    final int centavos = (value * 100).round();
    return AppFormatters.formatCurrencyInputFromCentavos(centavos);
  }

  Future<void> bootstrap() async {
    final String? vehicleId = Get.parameters['vehicleId'];
    final String? resumeServiceId = Get.parameters['resumeServiceId'];
    if (vehicleId == null || vehicleId.isEmpty) {
      errorMessage.value = 'Veículo inválido';
      return;
    }
    final Either<Failure, VehicleWithClient> vehicleResult = await _repository
        .getVehicleWithClient(vehicleId);
    final bool isVehicleOk = vehicleResult.fold(
      (Failure failure) {
        errorMessage.value = failure.message;
        return false;
      },
      (VehicleWithClient value) {
        vehicle.value = value;
        return true;
      },
    );
    if (!isVehicleOk) {
      return;
    }
    if (resumeServiceId != null && resumeServiceId.isNotEmpty) {
      final Either<Failure, ServiceRecord> resumeResult = await _repository
          .getServiceById(resumeServiceId);
      resumeResult.fold(
        (Failure failure) => errorMessage.value = failure.message,
        (ServiceRecord record) {
          if (record.veiculoId != vehicleId) {
            errorMessage.value =
                'Atendimento não corresponde ao veículo selecionado';
            return;
          }
          if (record.status != ServiceStatus.emAndamento) {
            errorMessage.value = 'Este atendimento não está em andamento';
            return;
          }
          errorMessage.value = '';
          serviceRecord.value = record;
          _syncFormFromRecord(record);
          final int elapsed =
              DateTime.now()
                  .toUtc()
                  .difference(record.horaEntrada.toUtc())
                  .inSeconds;
          elapsedSeconds.value = elapsed < 0 ? 0 : elapsed;
          startTimer();
        },
      );
      return;
    }
    final Either<Failure, ServiceRecord> serviceResult =
        await _startService(vehicleId);
    serviceResult.fold(
      (Failure failure) => errorMessage.value = failure.message,
      (ServiceRecord record) {
        errorMessage.value = '';
        serviceRecord.value = record;
        _syncFormFromRecord(record);
        elapsedSeconds.value = 0;
        startTimer();
      },
    );
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsedSeconds.value++;
    });
  }

  Future<void> addServiceDetails() async {
    final ServiceRecord? record = serviceRecord.value;
    if (record == null) {
      return;
    }
    final double? valor = AppFormatters.parseMoneyInput(valorController.text);
    if (valor == null) {
      AppSnackbar.showError('Informe um valor válido.');
      return;
    }
    final String nome = nomeServicoController.text.trim();
    final String obs = observacaoController.text.trim();
    isAddingDetails.value = true;
    final Either<Failure, ServiceRecord> result = await _repository
        .updateServiceDetails(
          serviceId: record.id,
          valor: valor,
          nomeServico: nome.isEmpty ? null : nome,
          observacao: obs.isEmpty ? null : obs,
        );
    isAddingDetails.value = false;
    result.fold((Failure failure) => AppSnackbar.showError(failure.message), (
      ServiceRecord updated,
    ) {
      serviceRecord.value = updated;
      _syncFormFromRecord(updated);
      AppSnackbar.showSuccess('Detalhes salvos com sucesso.');
      if (Get.isRegistered<ReportController>()) {
        Get.find<ReportController>().loadInProgressServices();
        Get.find<ReportController>().loadDaily();
        Get.find<ReportController>().loadMonthly();
      }
    });
  }

  Future<void> openWhatsApp() async {
    final VehicleWithClient? current = vehicle.value;
    if (current == null) {
      return;
    }
    await WhatsAppService.openChatWithPrefilledText(
      phoneDigitsOnly: current.client.telefone,
      message:
          'Olá ${current.client.nome}! Seu veículo de placa ${current.vehicle.placa} está pronto para retirada.',
    );
  }

  void goToPayment() {
    final ServiceRecord? record = serviceRecord.value;
    if (record == null || !paymentFormValid.value) {
      return;
    }
    _timer?.cancel();
    final VehicleWithClient? v = vehicle.value;
    final String nomeTrim = nomeServicoController.text.trim();
    Get.toNamed<void>(
      '${AppRoutes.payment}/${record.id}',
      arguments: <String, dynamic>{
        'nomeServico':
            nomeTrim.isNotEmpty ? nomeTrim : record.nomeServico,
        'placa': v?.vehicle.placa,
        'horaEntrada': record.horaEntrada.toIso8601String(),
        'valorFormatted': valorController.text.trim(),
      },
    );
  }

  Future<void> cancelService() async {
    final ServiceRecord? record = serviceRecord.value;
    if (record == null) {
      Get.back<void>();
      return;
    }
    final bool? confirmed = await AppDialog.show(
      title: 'Cancelar atendimento',
      message:
          'Confirma o cancelamento deste atendimento? '
          'O status será alterado para cancelado.',
      confirmLabel: 'Cancelar atendimento',
      confirmIsDestructive: true,
    );
    if (confirmed != true) {
      return;
    }
    await _executeCancelService(record.id);
  }

  Future<void> _executeCancelService(String serviceId) async {
    final Either<Failure, Unit> result = await _repository.cancelService(
      serviceId,
    );
    result.fold((Failure failure) => AppSnackbar.showError(failure.message), (
      _,
    ) {
      _timer?.cancel();
      AppSnackbar.showSuccess('Atendimento cancelado com sucesso.');
      if (Get.isRegistered<ReportController>()) {
        Get.find<ReportController>().loadInProgressServices();
        Get.find<ReportController>().loadDaily();
        Get.find<ReportController>().loadMonthly();
      }

      Get.close(1);
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    nomeServicoController.removeListener(_syncPaymentFormValidity);
    valorController.removeListener(_syncPaymentFormValidity);
    nomeServicoController.dispose();
    valorController.dispose();
    observacaoController.dispose();
    super.onClose();
  }
}
