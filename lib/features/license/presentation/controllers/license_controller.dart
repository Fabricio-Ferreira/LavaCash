import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../../../../app/app_global_controller.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/device_id_service.dart';
import '../../../../domain/entities/license.dart';
import '../../domain/usecases/activate_license.dart';
import '../../domain/usecases/check_license.dart';

class LicenseController extends GetxController {
  LicenseController({
    required CheckLicense checkLicense,
    required ActivateLicense activateLicense,
  }) : _checkLicense = checkLicense,
       _activateLicense = activateLicense;

  final CheckLicense _checkLicense;
  final ActivateLicense _activateLicense;

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
    result.fold(
      (Failure failure) {
        blockedReason.value = failure.message;
        log('LicenseCheck | BLOCKED: ${failure.message}');
        isChecking.value = false;
        Get.offNamed<void>(AppRoutes.blocked, arguments: failure.message);
      },
      (License license) {
        global.establishmentName.value = license.establishmentName;
        global.licenseType.value = license.licenseType;
        log('LicenseCheck | OK: ${license.establishmentName}');
        isChecking.value = false;
        Get.offNamed<void>(AppRoutes.home);
      },
    );
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
    isActivating.value = false;
    result.fold(
      (Failure failure) {
        blockedReason.value = failure.message;
      },
      (License license) {
        global.establishmentName.value = license.establishmentName;
        global.licenseType.value = license.licenseType;
        Get.offNamed<void>(AppRoutes.home);
      },
    );
  }
}
