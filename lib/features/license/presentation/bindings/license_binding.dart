import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_initializer.dart';
import '../../data/repositories/license_repository_impl.dart';
import '../../domain/repositories/license_repository.dart';
import '../../domain/usecases/check_license.dart';
import '../controllers/license_controller.dart';

class LicenseBinding extends Bindings {
  @override
  void dependencies() {
    final SupabaseClient? client = SupabaseInitializer.clientOrNull;
    Get.lazyPut<LicenseRepository>(
      () => LicenseRepositoryImpl(client: client),
      fenix: true,
    );
    Get.lazyPut<CheckLicense>(
      () => CheckLicense(repository: Get.find<LicenseRepository>()),
      fenix: true,
    );
    Get.lazyPut<LicenseController>(
      () => LicenseController(checkLicense: Get.find<CheckLicense>()),
      fenix: true,
    );
  }
}
