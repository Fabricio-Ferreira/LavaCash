import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/license_supabase_client.dart';
import '../../../../core/services/license_encrypted_local_cache.dart';
import '../../data/repositories/license_repository_impl.dart';
import '../../domain/repositories/license_repository.dart';
import '../../domain/usecases/activate_license.dart';
import '../../domain/usecases/check_license.dart';
import '../controllers/license_controller.dart';

class LicenseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SupabaseClient>(
      () => LicenseSupabaseClient.create(),
      tag: 'license',
      fenix: true,
    );
    Get.lazyPut<LicenseEncryptedLocalCache>(
      () => LicenseEncryptedLocalCache(),
      fenix: true,
    );
    Get.lazyPut<LicenseRepository>(
      () => LicenseRepositoryImpl(
        client: Get.find<SupabaseClient>(tag: 'license'),
        localCache: Get.find<LicenseEncryptedLocalCache>(),
      ),
      fenix: true,
    );
    Get.lazyPut<CheckLicense>(
      () => CheckLicense(repository: Get.find<LicenseRepository>()),
      fenix: true,
    );
    Get.lazyPut<ActivateLicense>(
      () => ActivateLicense(repository: Get.find<LicenseRepository>()),
      fenix: true,
    );
    Get.lazyPut<LicenseController>(
      () => LicenseController(
        checkLicense: Get.find<CheckLicense>(),
        activateLicense: Get.find<ActivateLicense>(),
      ),
      fenix: true,
    );
  }
}
