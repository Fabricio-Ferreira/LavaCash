import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_initializer.dart';
import '../../data/repositories/service_repository_impl.dart';
import '../../domain/repositories/service_repository.dart';
import '../controllers/service_controller.dart';

class ServiceBinding extends Bindings {
  @override
  void dependencies() {
    final SupabaseClient? client = SupabaseInitializer.clientOrNull;
    Get.lazyPut<ServiceRepository>(
      () => ServiceRepositoryImpl(client: client),
      fenix: true,
    );
    Get.lazyPut<ServiceController>(
      () => ServiceController(repository: Get.find<ServiceRepository>()),
      fenix: true,
    );
  }
}
