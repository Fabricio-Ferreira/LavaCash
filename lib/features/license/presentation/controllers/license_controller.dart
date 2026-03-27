import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../../../../app/app_global_controller.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/supabase_initializer.dart';
import '../../../../core/services/device_id_service.dart';
import '../../../../domain/entities/license.dart';
import '../../domain/usecases/check_license.dart';

class LicenseController extends GetxController {
  LicenseController({required CheckLicense checkLicense})
    : _checkLicense = checkLicense;

  final CheckLicense _checkLicense;

  final RxBool isChecking = true.obs;
  final RxString blockedReason = ''.obs;

  @override
  void onReady() {
    super.onReady();
    verifyOnStartup();
  }

  Future<void> verifyOnStartup() async {
    isChecking.value = true;
    blockedReason.value = '';
    final String deviceId = await DeviceIdService.getDeviceId();
    final AppGlobalController global = Get.find<AppGlobalController>();
    global.deviceId.value = deviceId;
    log('LicenseCheck | deviceId=$deviceId');
    log('LicenseCheck | isConfigured=${SupabaseInitializer.isConfigured}');
    log('LicenseCheck | clientOrNull=${SupabaseInitializer.clientOrNull != null}');
    if (!SupabaseInitializer.isConfigured) {
      blockedReason.value = 'Supabase não configurado';
      log('LicenseCheck | BLOCKED: Supabase not configured');
      Get.offNamed<void>(AppRoutes.blocked);
      return;
    }
    if (SupabaseInitializer.clientOrNull == null) {
      blockedReason.value = 'Supabase client indisponível';
      log('LicenseCheck | BLOCKED: clientOrNull is null');
      Get.offNamed<void>(AppRoutes.blocked);
      return;
    }
    await Future<void>.delayed(const Duration(seconds: 3));
    final Either<Failure, License> result = await _checkLicense(deviceId);
    result.fold(
      (Failure failure) {
        blockedReason.value = failure.message;
        log('LicenseCheck | BLOCKED: ${failure.message}');
        isChecking.value = false;
        Get.offNamed<void>(AppRoutes.blocked);
      },
      (License license) {
        global.nomeLavagem.value = license.nomeLavagem;
        log('LicenseCheck | OK: ${license.nomeLavagem}');
        isChecking.value = false;
        Get.offNamed<void>(AppRoutes.home);
      },
    );
  }
}
