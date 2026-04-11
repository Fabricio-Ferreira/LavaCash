import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_initializer.dart';
import 'package:lava_cash/core/data/app_update/datasources/app_update_remote_datasource.dart';
import 'package:lava_cash/core/data/app_update/repositories/app_update_repository_impl.dart';
import 'package:lava_cash/core/domain/app_update/repositories/app_update_repository.dart';
import 'package:lava_cash/core/domain/app_update/usecases/check_for_update.dart';
import 'package:lava_cash/core/domain/app_update/usecases/get_apk_download_url.dart';
import 'package:lava_cash/features/app_update/presentation/controllers/app_update_controller.dart';
import 'package:lava_cash/features/license/presentation/bindings/license_binding.dart';
import 'package:lava_cash/core/data/search/repositories/search_repository_impl.dart';
import 'package:lava_cash/core/domain/search/repositories/search_repository.dart';
import 'package:lava_cash/core/domain/search/usecases/search_vehicle.dart';
import 'package:lava_cash/features/search/presentation/controllers/search_controller.dart'
    show VehicleSearchController;
import 'package:lava_cash/core/data/reports/repositories/report_repository_impl.dart';
import 'package:lava_cash/core/domain/reports/repositories/report_repository.dart';
import 'package:lava_cash/core/domain/reports/usecases/get_best_weekday_report.dart';
import 'package:lava_cash/core/domain/reports/usecases/get_daily_report.dart';
import 'package:lava_cash/core/domain/reports/usecases/get_in_progress_services.dart';
import 'package:lava_cash/core/domain/reports/usecases/get_interval_report.dart';
import 'package:lava_cash/core/domain/reports/usecases/get_monthly_reports.dart';
import 'package:lava_cash/core/domain/reports/usecases/get_today_services.dart';
import 'package:lava_cash/core/domain/reports/usecases/get_weekly_report.dart';
import 'package:lava_cash/features/reports/presentation/controllers/interval_report_controller.dart';
import 'package:lava_cash/features/reports/presentation/controllers/report_controller.dart';
import 'package:lava_cash/features/reports/services/report_pdf_service.dart';
import '../presentation/controllers/dashboard_controller.dart';
import '../presentation/controllers/home_tab_controller.dart';

class HomeBinding extends Bindings {
  /// Ensures [DashboardController] exists (cold start via [dependencies], or
  /// hot reload when bindings do not re-run).
  static void ensureDashboardController() {
    if (Get.isRegistered<DashboardController>()) {
      return;
    }
    Get.put<DashboardController>(
      DashboardController(reportController: Get.find<ReportController>()),
      permanent: true,
    );
  }

  @override
  void dependencies() {
    LicenseBinding.registerDependenciesIfNeeded();
    final SupabaseClient? client = SupabaseInitializer.clientOrNull;
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
    Get.lazyPut<ReportRepository>(
      () => ReportRepositoryImpl(client: client),
      fenix: true,
    );
    Get.lazyPut<ReportPdfService>(() => ReportPdfService(), fenix: true);
    Get.lazyPut<GetDailyReport>(
      () => GetDailyReport(repository: Get.find<ReportRepository>()),
      fenix: true,
    );
    Get.lazyPut<GetTodayServices>(
      () => GetTodayServices(repository: Get.find<ReportRepository>()),
      fenix: true,
    );
    Get.lazyPut<GetInProgressServices>(
      () => GetInProgressServices(repository: Get.find<ReportRepository>()),
      fenix: true,
    );
    Get.lazyPut<GetMonthlyReports>(
      () => GetMonthlyReports(repository: Get.find<ReportRepository>()),
      fenix: true,
    );
    Get.lazyPut<GetWeeklyReport>(
      () => GetWeeklyReport(repository: Get.find<ReportRepository>()),
      fenix: true,
    );
    Get.lazyPut<GetBestWeekdayReport>(
      () => GetBestWeekdayReport(repository: Get.find<ReportRepository>()),
      fenix: true,
    );
    Get.lazyPut<GetIntervalReport>(
      () => GetIntervalReport(repository: Get.find<ReportRepository>()),
      fenix: true,
    );
    Get.lazyPut<IntervalReportController>(
      () => IntervalReportController(
        getIntervalReport: Get.find<GetIntervalReport>(),
        reportRepository: Get.find<ReportRepository>(),
      ),
      fenix: true,
    );
    Get.lazyPut<ReportController>(
      () => ReportController(
        getDailyReport: Get.find<GetDailyReport>(),
        getTodayServices: Get.find<GetTodayServices>(),
        getInProgressServices: Get.find<GetInProgressServices>(),
        getMonthlyReports: Get.find<GetMonthlyReports>(),
        getWeeklyReport: Get.find<GetWeeklyReport>(),
        getBestWeekdayReport: Get.find<GetBestWeekdayReport>(),
      ),
      fenix: true,
    );
    Get.lazyPut<HomeTabController>(() => HomeTabController(), fenix: true);
    Get.lazyPut<AppUpdateRemoteDataSource>(
      () => AppUpdateRemoteDataSource(client: client),
      fenix: true,
    );
    Get.lazyPut<AppUpdateRepository>(
      () => AppUpdateRepositoryImpl(
        remoteDataSource: Get.find<AppUpdateRemoteDataSource>(),
      ),
      fenix: true,
    );
    Get.lazyPut<CheckForUpdate>(
      () => CheckForUpdate(repository: Get.find<AppUpdateRepository>()),
      fenix: true,
    );
    Get.lazyPut<GetApkDownloadUrl>(
      () => GetApkDownloadUrl(repository: Get.find<AppUpdateRepository>()),
      fenix: true,
    );
    Get.lazyPut<AppUpdateController>(
      () => AppUpdateController(
        checkForUpdate: Get.find<CheckForUpdate>(),
        getApkDownloadUrl: Get.find<GetApkDownloadUrl>(),
      ),
      fenix: true,
    );
    ensureDashboardController();
  }
}
