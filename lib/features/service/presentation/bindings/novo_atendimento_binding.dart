import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_initializer.dart';
import '../../../../core/services/recent_clients_cache.dart';
import 'package:lava_cash/core/data/search/repositories/search_repository_impl.dart';
import 'package:lava_cash/core/domain/search/repositories/search_repository.dart';
import 'package:lava_cash/core/domain/search/usecases/search_vehicle.dart';
import 'package:lava_cash/features/search/presentation/controllers/search_controller.dart'
    show VehicleSearchController;

class NovoAtendimentoBinding extends Bindings {
  @override
  void dependencies() {
    final SupabaseClient? client = SupabaseInitializer.clientOrNull;
    Get.lazyPut<RecentClientsCache>(() => RecentClientsCache(), fenix: true);
    Get.lazyPut<SearchRepository>(
      () => SearchRepositoryImpl(client: client),
      fenix: true,
    );
    Get.lazyPut<SearchVehicle>(
      () => SearchVehicle(repository: Get.find<SearchRepository>()),
      fenix: true,
    );
    Get.lazyPut<VehicleSearchController>(
      () => VehicleSearchController(searchVehicle: Get.find<SearchVehicle>()),
      fenix: true,
    );
  }
}
