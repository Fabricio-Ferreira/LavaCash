import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_initializer.dart';
import '../../../search/data/repositories/search_repository_impl.dart';
import '../../../search/domain/repositories/search_repository.dart';
import '../../../search/domain/usecases/search_vehicle.dart';
import '../../../search/presentation/controllers/search_controller.dart'
    show VehicleSearchController;
import '../../data/repositories/report_repository_impl.dart';
import '../../domain/repositories/report_repository.dart';
import '../../domain/usecases/get_best_weekday_report.dart';
import '../../domain/usecases/get_daily_report.dart';
import '../../domain/usecases/get_monthly_reports.dart';
import '../../domain/usecases/get_weekly_report.dart';
import '../controllers/home_tab_controller.dart';
import '../controllers/report_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
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
        getMonthlyReports: Get.find<GetMonthlyReports>(),
        getWeeklyReport: Get.find<GetWeeklyReport>(),
        getBestWeekdayReport: Get.find<GetBestWeekdayReport>(),
      ),
      fenix: true,
    );
    Get.lazyPut<HomeTabController>(
      () => HomeTabController(),
      fenix: true,
    );
  }
}
