import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_initializer.dart';
import '../../../app_update/data/datasources/app_update_remote_datasource.dart';
import '../../../app_update/data/repositories/app_update_repository_impl.dart';
import '../../../app_update/domain/repositories/app_update_repository.dart';
import '../../../app_update/domain/usecases/check_for_update.dart';
import '../../../app_update/domain/usecases/get_apk_download_url.dart';
import '../../../app_update/presentation/controllers/app_update_controller.dart';
import '../../../license/presentation/bindings/license_binding.dart';
import '../../../search/data/repositories/search_repository_impl.dart';
import '../../../search/domain/repositories/search_repository.dart';
import '../../../search/domain/usecases/search_vehicle.dart';
import '../../../search/presentation/controllers/search_controller.dart'
    show VehicleSearchController;
import '../../data/repositories/report_repository_impl.dart';
import '../../domain/repositories/report_repository.dart';
import '../../domain/usecases/get_best_weekday_report.dart';
import '../../domain/usecases/get_daily_report.dart';
import '../../domain/usecases/get_in_progress_services.dart';
import '../../domain/usecases/get_monthly_reports.dart';
import '../../domain/usecases/get_today_services.dart';
import '../../domain/usecases/get_weekly_report.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/home_tab_controller.dart';
import '../controllers/report_controller.dart';

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
