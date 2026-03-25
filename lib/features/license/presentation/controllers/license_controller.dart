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

  @override
  void onReady() {
    super.onReady();
    verifyOnStartup();
  }

  Future<void> verifyOnStartup() async {
    isChecking.value = true;
    final String deviceId = await DeviceIdService.getDeviceId();
    Get.find<AppGlobalController>().deviceId.value = deviceId;
    if (!SupabaseInitializer.isConfigured) {
      isChecking.value = true;
      Get.offNamed<void>(AppRoutes.blocked);
      return;
    }
    await Future<void>.delayed(const Duration(seconds: 3));
    final Either<Failure, License> result = await _checkLicense(deviceId);
    result.fold(
      (Failure failure) {
        isChecking.value = false;
        Get.offNamed<void>(AppRoutes.blocked);
      },
      (License license) {
        Get.find<AppGlobalController>().nomeLavagem.value = license.nomeLavagem;
        isChecking.value = false;
        Get.offNamed<void>(AppRoutes.home);
      },
    );
  }
}
