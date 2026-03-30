import 'package:get/get.dart';

import '../../../../core/network/supabase_initializer.dart';
import '../../data/repositories/empresa_repository_impl.dart';
import '../../domain/repositories/empresa_repository.dart';
import '../controllers/empresa_controller.dart';

class EmpresaBinding extends Bindings {
  static void registerDependenciesIfNeeded() {
    if (Get.isRegistered<EmpresaController>()) return;
    if (!Get.isRegistered<EmpresaRepository>()) {
      Get.lazyPut<EmpresaRepository>(
        () => EmpresaRepositoryImpl(client: SupabaseInitializer.clientOrNull),
        fenix: true,
      );
    }
    Get.lazyPut<EmpresaController>(
      () => EmpresaController(
        empresaRepository: Get.find<EmpresaRepository>(),
      ),
      fenix: true,
    );
  }

  @override
  void dependencies() => registerDependenciesIfNeeded();
}
