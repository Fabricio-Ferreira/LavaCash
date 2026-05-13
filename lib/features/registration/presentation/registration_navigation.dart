import 'package:get/get.dart';

import '../../../core/domain/entities/vehicle_with_client.dart';
import 'bindings/registration_binding.dart';
import 'pages/registration_flow_page.dart';

abstract final class RegistrationNavigation {
  /// Opens registration/edit flow; completes with [VehicleWithClient] after edit
  /// save, or `null` if dismissed / duplicate route suppressed.
  static Future<VehicleWithClient?> pushModal({
    VehicleWithClient? editInitial,
  }) async {
    final Future<VehicleWithClient?>? pending = Get.to<VehicleWithClient?>(
      () => const RegistrationFlowPage(),
      binding: RegistrationBinding(),
      arguments: editInitial,
    );
    if (pending == null) {
      return null;
    }
    return pending;
  }
}
