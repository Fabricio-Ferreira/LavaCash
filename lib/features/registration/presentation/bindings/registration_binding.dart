import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_initializer.dart';
import 'package:lava_cash/core/data/registration/repositories/registration_repository_impl.dart';
import 'package:lava_cash/core/domain/registration/repositories/registration_repository.dart';
import 'package:lava_cash/core/domain/registration/usecases/register_client_and_vehicle.dart';
import 'package:lava_cash/core/domain/registration/usecases/update_client_and_vehicle.dart';
import '../controllers/registration_controller.dart';

class RegistrationBinding extends Bindings {
  @override
  void dependencies() {
    final SupabaseClient? client = SupabaseInitializer.clientOrNull;
    Get.lazyPut<RegistrationRepository>(
      () => RegistrationRepositoryImpl(client: client),
      fenix: true,
    );
    Get.lazyPut<RegisterClientAndVehicle>(
      () => RegisterClientAndVehicle(
        repository: Get.find<RegistrationRepository>(),
      ),
      fenix: true,
    );
    Get.lazyPut<UpdateClientAndVehicle>(
      () => UpdateClientAndVehicle(
        repository: Get.find<RegistrationRepository>(),
      ),
      fenix: true,
    );
    Get.lazyPut<RegistrationController>(
      () => RegistrationController(
        register: Get.find<RegisterClientAndVehicle>(),
        updateClientAndVehicle: Get.find<UpdateClientAndVehicle>(),
      ),
      fenix: true,
    );
  }
}
