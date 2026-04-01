import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../../../../app/app_global_controller.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/device_id_service.dart';
import '../../../../domain/entities/license.dart';
import '../../../auth/domain/entities/user_session.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../empresa/presentation/controllers/empresa_controller.dart';
import '../../domain/usecases/activate_license.dart';
import '../../domain/usecases/check_license.dart';

class LicenseController extends GetxController {
  LicenseController({
    required CheckLicense checkLicense,
    required ActivateLicense activateLicense,
    required AuthRepository authRepository,
    required EmpresaController empresaController,
  }) : _checkLicense = checkLicense,
       _activateLicense = activateLicense,
       _authRepository = authRepository,
       _empresaController = empresaController;

  final CheckLicense _checkLicense;
  final ActivateLicense _activateLicense;
  final AuthRepository _authRepository;
  final EmpresaController _empresaController;

  final RxBool isChecking = true.obs;
  final RxBool isActivating = false.obs;
  final RxString blockedReason = ''.obs;

  void _applyBlockedReasonFromRouteArguments() {
    final Object? raw = Get.arguments;
    if (raw is String && raw.isNotEmpty) {
      blockedReason.value = raw;
    }
  }

  @override
  void onReady() {
    super.onReady();
    if (Get.currentRoute == AppRoutes.blocked) {
      isChecking.value = false;
      _applyBlockedReasonFromRouteArguments();
      return;
    }
    verifyOnStartup();
  }

  Future<void> verifyOnStartup() async {
    isChecking.value = true;
    blockedReason.value = '';
    final String deviceId = await DeviceIdService.getDeviceId();
    final AppGlobalController global = Get.find<AppGlobalController>();
    global.deviceId.value = deviceId;
    log('LicenseCheck | deviceId=$deviceId');
    await Future<void>.delayed(const Duration(seconds: 3));
    final Either<Failure, License> result = await _checkLicense(deviceId);
    if (result.isLeft()) {
      final Failure failure = result.fold(
        (Failure f) => f,
        (License _) => throw StateError('Expected Left'),
      );
      blockedReason.value = failure.message;
      log('LicenseCheck | BLOCKED: ${failure.message}');
      isChecking.value = false;
      Get.offNamed<void>(AppRoutes.blocked, arguments: failure.message);
      return;
    }
    final License license = result.fold(
      (Failure _) => throw StateError('Expected Right'),
      (License l) => l,
    );
    global.establishmentName.value = license.establishmentName;
    global.establishmentPhone.value = license.phone;
    global.licenseType.value = license.licenseType;
    global.activationCode.value = license.activationCode ?? '';
    log('LicenseCheck | OK: ${license.establishmentName}');
    await _completeAuthAndNavigate(global);
  }

  Future<void> activateWithKey(String activationKey) async {
    final String trimmed = activationKey.trim();
    if (trimmed.isEmpty) {
      blockedReason.value = 'Digite o ID da licença (UUID).';
      return;
    }
    isActivating.value = true;
    blockedReason.value = '';
    final String deviceId = await DeviceIdService.getDeviceId();
    final AppGlobalController global = Get.find<AppGlobalController>();
    global.deviceId.value = deviceId;
    final Either<Failure, License> result = await _activateLicense(
      deviceId: deviceId,
      activationKey: trimmed,
    );
    if (result.isLeft()) {
      final Failure failure = result.fold(
        (Failure f) => f,
        (License _) => throw StateError('Expected Left'),
      );
      blockedReason.value = failure.message;
      isActivating.value = false;
      return;
    }
    final License license = result.fold(
      (Failure _) => throw StateError('Expected Right'),
      (License l) => l,
    );
    global.establishmentName.value = license.establishmentName;
    global.establishmentPhone.value = license.phone;
    global.licenseType.value = license.licenseType;
    global.activationCode.value = license.activationCode ?? '';
    await _completeAuthAndNavigate(global);
  }

  Future<void> _completeAuthAndNavigate(AppGlobalController global) async {
    final String code = global.activationCode.value;
    final Either<Failure, UserSession> authEither = await _authRepository
        .signInOrSignUpWithActivationCode(code);
    if (authEither.isLeft()) {
      final Failure failure = authEither.fold(
        (Failure f) => f,
        (_) => throw StateError('Expected Left'),
      );
      log('LicenseCheck | auth falhou: ${failure.message}');
      isChecking.value = false;
      isActivating.value = false;
      blockedReason.value = failure.message;
      Get.offNamed<void>(AppRoutes.blocked, arguments: failure.message);
      return;
    }
    final bool ok = await _empresaController.loadOrClaim(
      code,
      nomeParaCriacao: global.establishmentName.value,
      telefoneParaCriacao: global.establishmentPhone.value,
    );
    log('LicenseCheck | empresa ok=$ok');
    if (!ok) {
      final String msg = _empresaController.errorMessage.value ??
          'Não foi possível configurar a empresa.';
      isChecking.value = false;
      isActivating.value = false;
      blockedReason.value = msg;
      Get.offNamed<void>(AppRoutes.blocked, arguments: msg);
      return;
    }
    isChecking.value = false;
    isActivating.value = false;
    Get.offAllNamed<void>(AppRoutes.home);
  }
}
