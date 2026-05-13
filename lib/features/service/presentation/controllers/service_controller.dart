import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../dashboard/presentation/controllers/home_tab_controller.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/whatsapp_service.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/utils/formatters.dart';
import 'package:lava_cash/core/domain/entities/attendance_service_line.dart';
import 'package:lava_cash/core/domain/entities/service_catalog_item.dart';
import 'package:lava_cash/core/domain/entities/service_record.dart';
import 'package:lava_cash/core/domain/entities/service_status.dart';
import 'package:lava_cash/core/domain/entities/vehicle_with_client.dart';
import 'package:lava_cash/core/domain/service_catalog/repositories/service_catalog_repository.dart';
import 'package:lava_cash/features/reports/presentation/controllers/report_controller.dart';
import 'package:lava_cash/core/domain/service/repositories/service_repository.dart';
import 'package:lava_cash/core/domain/service/usecases/start_service.dart';
import '../logic/service_attendance_pricing.dart';

class ServiceController extends GetxController {
  ServiceController({
    required ServiceRepository repository,
    required ServiceCatalogRepository catalogRepository,
    required StartService startService,
  }) : _repository = repository,
       _catalogRepository = catalogRepository,
       _startService = startService;

  final ServiceRepository _repository;
  final ServiceCatalogRepository _catalogRepository;
  final StartService _startService;

  // —— Reactive state (SSOT for this screen) ——
  final Rxn<VehicleWithClient> vehicle = Rxn<VehicleWithClient>();
  final Rxn<ServiceRecord> serviceRecord = Rxn<ServiceRecord>();
  final RxInt elapsedSeconds = 0.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isAddingDetails = false.obs;
  final RxBool paymentFormValid = false.obs;
  final RxList<AttendanceServiceLine> attendanceLines =
      <AttendanceServiceLine>[].obs;
  final RxList<ServiceCatalogItem> quickSuggestions =
      <ServiceCatalogItem>[].obs;

  /// See [ServiceAttendancePricing.resolveDisplayTotal] (line-item mode flag).
  final RxBool lineItemsDriveTotal = false.obs;
  final RxBool isLinesLoading = false.obs;

  /// Triggers [Obx] when form fields change ([TextEditingController] is not rx).
  final RxInt formFieldsRevision = 0.obs;

  final TextEditingController nomeServicoController = TextEditingController();
  final TextEditingController valorController = TextEditingController();
  final TextEditingController observacaoController = TextEditingController();

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    nomeServicoController.addListener(_onPaymentFormFieldsChanged);
    valorController.addListener(_onPaymentFormFieldsChanged);
    ever(attendanceLines, (_) => _syncPaymentFormValidity());
    bootstrap();
  }

  // —— Derived totals & payment gate ——
  double get attendanceTotalValor {
    final int _ = formFieldsRevision.value;
    return ServiceAttendancePricing.resolveDisplayTotal(
      lines: attendanceLines.toList(),
      lineItemsDriveTotal: lineItemsDriveTotal.value,
      record: serviceRecord.value,
      valorFieldText: valorController.text,
    );
  }

  void _onPaymentFormFieldsChanged() {
    formFieldsRevision.value++;
    _syncPaymentFormValidity();
  }

  void _syncPaymentFormValidity() {
    paymentFormValid.value = ServiceAttendancePricing.isPaymentFormSatisfied(
      lines: attendanceLines.toList(),
      nomeFieldText: nomeServicoController.text,
      valorFieldText: valorController.text,
    );
  }

  void _syncFormFromRecord(ServiceRecord record) {
    nomeServicoController.text = record.nomeServico ?? '';
    observacaoController.text = record.observacao ?? '';
    if (record.valor != null) {
      valorController.text = _formatValorForField(record.valor!);
    } else {
      valorController.clear();
    }
    formFieldsRevision.value++;
    _syncPaymentFormValidity();
  }

  void _clearPersonalizedServiceForm() {
    nomeServicoController.clear();
    valorController.clear();
    observacaoController.clear();
    formFieldsRevision.value++;
    _syncPaymentFormValidity();
  }

  String _formatValorForField(double value) {
    final int centavos = (value * 100).round();
    return AppFormatters.formatCurrencyInputFromCentavos(centavos);
  }

  String _paymentServiceLabel(ServiceRecord record) {
    return ServiceAttendancePricing.paymentServiceLabel(
      lines: attendanceLines.toList(),
      nomeFieldText: nomeServicoController.text,
      record: record,
    );
  }

  // —— Bootstrap & session timer ——
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
    await _loadQuickSuggestions();
    if (resumeServiceId != null && resumeServiceId.isNotEmpty) {
      await _bootstrapResume(
        vehicleId: vehicleId,
        resumeServiceId: resumeServiceId,
      );
      return;
    }
    await _bootstrapNewService(vehicleId);
  }

  Future<void> _bootstrapResume({
    required String vehicleId,
    required String resumeServiceId,
  }) async {
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
        _applyElapsedFromRecord(record);
        startTimer();
        _loadAttendanceLines(record.id);
      },
    );
  }

  void _applyElapsedFromRecord(ServiceRecord record) {
    final int elapsed =
        DateTime.now().toUtc().difference(record.horaEntrada.toUtc()).inSeconds;
    elapsedSeconds.value = elapsed < 0 ? 0 : elapsed;
  }

  Future<void> _bootstrapNewService(String vehicleId) async {
    final Either<Failure, ServiceRecord> serviceResult = await _startService(
      vehicleId,
    );
    serviceResult.fold(
      (Failure failure) => errorMessage.value = failure.message,
      (ServiceRecord record) {
        errorMessage.value = '';
        serviceRecord.value = record;
        _syncFormFromRecord(record);
        elapsedSeconds.value = 0;
        startTimer();
        _loadAttendanceLines(record.id);
      },
    );
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsedSeconds.value++;
    });
  }

  // —— Catalog suggestions ——
  Future<void> _loadQuickSuggestions() async {
    final Either<Failure, List<ServiceCatalogItem>> result =
        await _catalogRepository.listMaisUtilizados();
    result.fold(
      (Failure failure) {
        quickSuggestions.clear();
      },
      (List<ServiceCatalogItem> list) {
        quickSuggestions.assignAll(list);
      },
    );
  }

  // —— Line items ——
  Future<void> _loadAttendanceLines(String atendimentoId) async {
    isLinesLoading.value = true;
    final Either<Failure, List<AttendanceServiceLine>> result =
        await _repository.listAttendanceServiceLines(atendimentoId);
    result.fold(
      (Failure failure) {
        AppSnackbar.showError(failure.message);
        attendanceLines.clear();
      },
      (List<AttendanceServiceLine> list) {
        attendanceLines.assignAll(list);
        if (list.isNotEmpty) {
          lineItemsDriveTotal.value = true;
        }
      },
    );
    isLinesLoading.value = false;
    _syncPaymentFormValidity();
  }

  Future<void> _refreshRecordAfterLinesChanged(String serviceId) async {
    final Either<Failure, ServiceRecord> refreshed = await _repository
        .getServiceById(serviceId);
    refreshed.fold(
      (Failure failure) => null,
      (ServiceRecord r) => serviceRecord.value = r,
    );
  }

  Future<void> addServiceDetails() async {
    final ServiceRecord? record = serviceRecord.value;
    if (record == null) {
      return;
    }
    final double? valor = AppFormatters.parseMoneyInput(valorController.text);
    if (valor == null || valor <= 0) {
      AppSnackbar.showError('Informe um valor válido.');
      return;
    }
    final String nome = nomeServicoController.text.trim();
    if (nome.isEmpty) {
      AppSnackbar.showError('Informe o nome do serviço.');
      return;
    }
    final String obs = observacaoController.text.trim();
    isAddingDetails.value = true;
    final Either<Failure, AttendanceServiceLine> lineResult = await _repository
        .addAttendanceServiceLine(
          atendimentoId: record.id,
          nome: nome,
          valor: valor,
          observacao: obs.isEmpty ? null : obs,
        );
    isAddingDetails.value = false;
    await lineResult.fold(
      (Failure failure) async {
        AppSnackbar.showError(failure.message);
      },
      (AttendanceServiceLine line) async {
        await _onLineAddedSuccessfully(
          record: record,
          line: line,
          clearPersonalizedForm: true,
          successMessage: 'Serviço adicionado ao atendimento.',
        );
      },
    );
  }

  Future<void> addLineFromCatalogItem(ServiceCatalogItem item) async {
    final ServiceRecord? record = serviceRecord.value;
    if (record == null) {
      return;
    }
    isAddingDetails.value = true;
    final Either<Failure, AttendanceServiceLine> lineResult = await _repository
        .addAttendanceServiceLine(
          atendimentoId: record.id,
          servicoCatalogoId: item.id,
          nome: item.nome,
          valor: item.valorPadrao,
          observacao:
              item.observacao != null && item.observacao!.trim().isNotEmpty
                  ? item.observacao
                  : null,
        );
    isAddingDetails.value = false;
    await lineResult.fold(
      (Failure failure) async {
        AppSnackbar.showError(failure.message);
      },
      (AttendanceServiceLine line) async {
        await _onLineAddedSuccessfully(
          record: record,
          line: line,
          clearPersonalizedForm: false,
          successMessage: '${item.nome} adicionado.',
        );
      },
    );
  }

  Future<void> addSelectedCatalogItemsToAttendance(
    List<ServiceCatalogItem> items,
  ) async {
    final ServiceRecord? record = serviceRecord.value;
    if (record == null || items.isEmpty) {
      return;
    }
    isAddingDetails.value = true;
    final List<AttendanceServiceLine> added = <AttendanceServiceLine>[];
    Failure? batchFailure;
    for (final ServiceCatalogItem item in items) {
      final Either<Failure, AttendanceServiceLine> lineResult =
          await _repository.addAttendanceServiceLine(
            atendimentoId: record.id,
            servicoCatalogoId: item.id,
            nome: item.nome,
            valor: item.valorPadrao,
            observacao:
                item.observacao != null && item.observacao!.trim().isNotEmpty
                    ? item.observacao
                    : null,
          );
      lineResult.fold((Failure f) {
        batchFailure = f;
      }, added.add);
      if (batchFailure != null) {
        break;
      }
    }
    isAddingDetails.value = false;
    if (batchFailure != null) {
      AppSnackbar.showError(batchFailure!.message);
      await _loadAttendanceLines(record.id);
      return;
    }
    if (added.isEmpty) {
      return;
    }
    lineItemsDriveTotal.value = true;
    attendanceLines.addAll(added);
    await _refreshRecordAfterLinesChanged(record.id);
    AppSnackbar.showSuccess(
      added.length == 1
          ? '${items.first.nome} adicionado.'
          : '${added.length} serviços adicionados ao atendimento.',
    );
    _syncPaymentFormValidity();
    _refreshReportsIfRegistered();
  }

  Future<void> _onLineAddedSuccessfully({
    required ServiceRecord record,
    required AttendanceServiceLine line,
    required bool clearPersonalizedForm,
    required String successMessage,
  }) async {
    lineItemsDriveTotal.value = true;
    attendanceLines.add(line);
    if (clearPersonalizedForm) {
      nomeServicoController.clear();
      valorController.clear();
      observacaoController.clear();
    }
    await _refreshRecordAfterLinesChanged(record.id);
    AppSnackbar.showSuccess(successMessage);
    _syncPaymentFormValidity();
    _refreshReportsIfRegistered();
  }

  Future<void> removeLine(AttendanceServiceLine line) async {
    isLinesLoading.value = true;
    final Either<Failure, Unit> result = await _repository
        .deleteAttendanceServiceLine(line.id);
    isLinesLoading.value = false;
    final ServiceRecord? record = serviceRecord.value;
    await result.fold(
      (Failure failure) async {
        AppSnackbar.showError(failure.message);
      },
      (_) async {
        attendanceLines.assignAll(
          attendanceLines
              .where((AttendanceServiceLine l) => l.id != line.id)
              .toList(),
        );
        if (record != null) {
          await _refreshRecordAfterLinesChanged(record.id);
        }
        if (attendanceLines.isEmpty && lineItemsDriveTotal.value) {
          _clearPersonalizedServiceForm();
        }
        AppSnackbar.showSuccess('Item removido.');
        _syncPaymentFormValidity();
        _refreshReportsIfRegistered();
      },
    );
  }

  void _refreshReportsIfRegistered() {
    if (!Get.isRegistered<ReportController>()) {
      return;
    }
    final ReportController reports = Get.find<ReportController>();
    reports.loadInProgressServices();
    reports.loadDaily();
    reports.loadMonthly();
  }

  // —— Side actions ——
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
    final String valorText = AppFormatters.formatCurrencyInputFromCentavos(
      (attendanceTotalValor * 100).round(),
    );
    Get.toNamed<void>(
      '${AppRoutes.payment}/${record.id}',
      arguments: <String, dynamic>{
        'nomeServico': _paymentServiceLabel(record),
        'placa': v?.vehicle.placa,
        'horaEntrada': record.horaEntrada.toIso8601String(),
        'valorFormatted': valorText,
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
      Get.offAllNamed<void>(AppRoutes.home);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.isRegistered<HomeTabController>()) {
          Get.find<HomeTabController>().setTab(0);
        }
        _refreshReportsIfRegistered();
      });
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    nomeServicoController.removeListener(_onPaymentFormFieldsChanged);
    valorController.removeListener(_onPaymentFormFieldsChanged);
    nomeServicoController.dispose();
    valorController.dispose();
    observacaoController.dispose();
    super.onClose();
  }
}
