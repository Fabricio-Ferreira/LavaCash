import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../../../../app/app_global_controller.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/device_id_service.dart';
import '../../../../domain/entities/license.dart';
import '../../domain/usecases/check_license.dart';
import '../bindings/license_binding.dart';

/// Re-validates license with the backend (same flow as startup check, without
/// splash delay). Used from home/dashboard refresh so revoked or expired
/// licenses redirect to [AppRoutes.blocked].
abstract class LicenseStatusRefresh {
  /// Returns `false` if license is invalid and navigation to blocked ran.
  static Future<bool> verifyAndSyncOrExit() async {
    LicenseBinding.registerDependenciesIfNeeded();
    final CheckLicense checkLicense = Get.find<CheckLicense>();
    final AppGlobalController global = Get.find<AppGlobalController>();
    final String deviceId =
        global.deviceId.value.isNotEmpty
            ? global.deviceId.value
            : await DeviceIdService.getDeviceId();
    global.deviceId.value = deviceId;
    final Either<Failure, License> result = await checkLicense(deviceId);
    return result.fold(
      (Failure failure) {
        log('LicenseStatusRefresh | BLOCKED: ${failure.message}');
        Get.offNamed<void>(AppRoutes.blocked, arguments: failure.message);
        return false;
      },
      (License license) {
        global.establishmentName.value = license.establishmentName;
        global.establishmentPhone.value = license.phone;
        global.licenseType.value = license.licenseType;
        log('LicenseStatusRefresh | OK: ${license.establishmentName}');
        return true;
      },
    );
  }
}
