import 'package:get/get.dart';

import '../features/auth/domain/entities/user_role.dart';

class AppGlobalController extends GetxController {
  final RxString establishmentName = ''.obs;
  final RxString establishmentPhone = ''.obs;
  final RxString licenseType = ''.obs;
  final RxString deviceId = ''.obs;
  final RxString empresaId = ''.obs;
  final RxString activationCode = ''.obs;
  final Rx<UserRole> userRole = UserRole.operador.obs;
}
