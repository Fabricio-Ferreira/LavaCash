import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_initializer.dart';
import 'package:lava_cash/core/data/service/repositories/service_repository_impl.dart';
import 'package:lava_cash/core/data/service_catalog/repositories/service_catalog_repository_impl.dart';
import 'package:lava_cash/core/domain/service/repositories/service_repository.dart';
import 'package:lava_cash/core/domain/service_catalog/repositories/service_catalog_repository.dart';
import 'package:lava_cash/core/domain/service/usecases/start_service.dart';
import '../controllers/service_controller.dart';

class ServiceBinding extends Bindings {
  @override
  void dependencies() {
    final SupabaseClient? client = SupabaseInitializer.clientOrNull;
    if (!Get.isRegistered<ServiceCatalogRepository>()) {
      Get.lazyPut<ServiceCatalogRepository>(
        () => ServiceCatalogRepositoryImpl(client: client),
        fenix: true,
      );
    }
    Get.lazyPut<ServiceRepository>(
      () => ServiceRepositoryImpl(client: client),
      fenix: true,
    );
    Get.lazyPut<StartService>(
      () => StartService(repository: Get.find<ServiceRepository>()),
      fenix: true,
    );
    Get.lazyPut<ServiceController>(
      () => ServiceController(
        repository: Get.find<ServiceRepository>(),
        catalogRepository: Get.find<ServiceCatalogRepository>(),
        startService: Get.find<StartService>(),
      ),
      fenix: true,
    );
  }
}
