import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/license_supabase_client.dart';
import '../../../../core/network/supabase_initializer.dart';
import '../../../../core/services/license_encrypted_local_cache.dart';
import 'package:lava_cash/core/data/auth/repositories/auth_repository_impl.dart';
import 'package:lava_cash/core/domain/auth/repositories/auth_repository.dart';
import 'package:lava_cash/features/empresa/presentation/bindings/empresa_binding.dart';
import 'package:lava_cash/features/empresa/presentation/controllers/empresa_controller.dart';
import 'package:lava_cash/core/data/license/repositories/license_repository_impl.dart';
import 'package:lava_cash/core/domain/license/repositories/license_repository.dart';
import 'package:lava_cash/core/domain/license/usecases/activate_license.dart';
import 'package:lava_cash/core/domain/license/usecases/check_license.dart';
import '../controllers/license_controller.dart';

class LicenseBinding extends Bindings {
  /// Registers license Supabase client, repository, and use cases so routes
  /// like [AppRoutes.home] can call [CheckLicense] without re-binding splash.
  static void registerDependenciesIfNeeded() {
    if (!Get.isRegistered<SupabaseClient>(tag: 'license')) {
      Get.lazyPut<SupabaseClient>(
        () => LicenseSupabaseClient.create(),
        tag: 'license',
        fenix: true,
      );
    }
    if (!Get.isRegistered<LicenseEncryptedLocalCache>()) {
      Get.lazyPut<LicenseEncryptedLocalCache>(
        () => LicenseEncryptedLocalCache(),
        fenix: true,
      );
    }
    if (!Get.isRegistered<LicenseRepository>()) {
      Get.lazyPut<LicenseRepository>(
        () => LicenseRepositoryImpl(
          client: Get.find<SupabaseClient>(tag: 'license'),
          localCache: Get.find<LicenseEncryptedLocalCache>(),
        ),
        fenix: true,
      );
    }
    if (!Get.isRegistered<CheckLicense>()) {
      Get.lazyPut<CheckLicense>(
        () => CheckLicense(repository: Get.find<LicenseRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<ActivateLicense>()) {
      Get.lazyPut<ActivateLicense>(
        () => ActivateLicense(repository: Get.find<LicenseRepository>()),
        fenix: true,
      );
    }
    EmpresaBinding.registerDependenciesIfNeeded();
    if (!Get.isRegistered<AuthRepository>()) {
      Get.lazyPut<AuthRepository>(
        () => AuthRepositoryImpl(client: SupabaseInitializer.clientOrNull),
        fenix: true,
      );
    }
  }

  @override
  void dependencies() {
    registerDependenciesIfNeeded();
    Get.lazyPut<LicenseController>(
      () => LicenseController(
        checkLicense: Get.find<CheckLicense>(),
        activateLicense: Get.find<ActivateLicense>(),
        authRepository: Get.find<AuthRepository>(),
        empresaController: Get.find<EmpresaController>(),
      ),
      fenix: true,
    );
  }
}

