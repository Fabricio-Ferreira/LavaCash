import 'package:get/get.dart';
import 'package:lava_cash/domain/entities/service_status.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../license/presentation/services/license_status_refresh.dart';
import 'report_controller.dart';

class DashboardController extends GetxController {
  DashboardController({required ReportController reportController})
      : _reportController = reportController;

  final ReportController _reportController;

  ReportController get reportController => _reportController;

  void loadInitialReportData() {
    _reportController.loadDaily();
    _reportController.loadMonthly();
  }

  Future<void> refreshDashboard() async {
    final bool licenseOk = await LicenseStatusRefresh.verifyAndSyncOrExit();
    if (!licenseOk) {
      return;
    }
    await _reportController.loadDaily();
    await _reportController.loadMonthly();
  }

  void openDailyReport() {
    _reportController.loadDaily();
    Get.toNamed<void>(AppRoutes.dailyReport);
  }

  void openMonthlyReport() {
    _reportController.loadMonthly();
    Get.toNamed<void>(AppRoutes.monthlyReport);
  }

  void openInProgressServices({ServiceStatus? status}) {
    _reportController.loadInProgressServices();
    Get.toNamed<void>(AppRoutes.inProgressServices, arguments: status);
  }
}
