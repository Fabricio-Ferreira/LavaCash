import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/whatsapp_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/entities/service_record.dart';
import '../../../../domain/entities/vehicle_with_client.dart';
import '../../domain/repositories/service_repository.dart';

class ServiceController extends GetxController {
  ServiceController({required ServiceRepository repository})
      : _repository = repository;

  final ServiceRepository _repository;

  final Rxn<VehicleWithClient> vehicle = Rxn<VehicleWithClient>();
  final Rxn<ServiceRecord> serviceRecord = Rxn<ServiceRecord>();
  final RxInt elapsedSeconds = 0.obs;
  final RxString errorMessage = ''.obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    bootstrap();
  }

  Future<void> bootstrap() async {
    final String? vehicleId = Get.parameters['vehicleId'];
    if (vehicleId == null) {
      errorMessage.value = 'Veículo inválido';
      return;
    }
    final Either<Failure, VehicleWithClient> vehicleResult =
        await _repository.getVehicleWithClient(vehicleId);
    vehicleResult.fold(
      (Failure failure) => errorMessage.value = failure.message,
      (VehicleWithClient value) => vehicle.value = value,
    );
    final Either<Failure, ServiceRecord> serviceResult =
        await _repository.startService(vehicleId);
    serviceResult.fold(
      (Failure failure) => errorMessage.value = failure.message,
      (ServiceRecord record) {
        serviceRecord.value = record;
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

  String get formattedElapsed {
    return AppFormatters.formatDurationFromSeconds(elapsedSeconds.value);
  }

  Future<void> openWhatsApp() async {
    final VehicleWithClient? current = vehicle.value;
    if (current == null) {
      return;
    }
    await WhatsAppService.sendReadyMessage(
      phone: current.client.telefone,
      name: current.client.nome,
      plate: current.vehicle.placa,
    );
  }

  void goToPayment() {
    final ServiceRecord? record = serviceRecord.value;
    if (record == null) {
      return;
    }
    _timer?.cancel();
    Get.toNamed<void>('${AppRoutes.payment}/${record.id}');
  }

  Future<void> cancelService() async {
    final ServiceRecord? record = serviceRecord.value;
    if (record == null) {
      Get.back<void>();
      return;
    }
    await _repository.cancelService(record.id);
    _timer?.cancel();
    Get.back<void>();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
