import 'package:get/get.dart';

import '../../../../core/network/supabase_initializer.dart';
import '../../data/repositories/usuarios_repository_impl.dart';
import '../../domain/repositories/usuarios_repository.dart';
import '../controllers/usuarios_controller.dart';

class UsuariosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UsuariosRepository>(
      () => UsuariosRepositoryImpl(client: SupabaseInitializer.clientOrNull),
    );
    Get.lazyPut<UsuariosController>(
      () => UsuariosController(usuariosRepository: Get.find()),
    );
  }
}
