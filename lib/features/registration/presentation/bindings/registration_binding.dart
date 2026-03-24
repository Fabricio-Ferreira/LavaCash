import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_initializer.dart';
import '../../data/repositories/registration_repository_impl.dart';
import '../../domain/repositories/registration_repository.dart';
import '../../domain/usecases/register_client_and_vehicle.dart';
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
    Get.lazyPut<RegistrationController>(
      () => RegistrationController(
        register: Get.find<RegisterClientAndVehicle>(),
      ),
      fenix: true,
    );
  }
}
