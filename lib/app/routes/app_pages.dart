import 'package:get/get.dart';
import 'package:lava_cash/domain/entities/service_status.dart';

import '../../features/license/presentation/bindings/license_binding.dart';
import '../../features/license/presentation/pages/blocked_page.dart';
import '../../features/license/presentation/pages/splash_page.dart';
import '../../features/payment/presentation/bindings/payment_binding.dart';
import '../../features/payment/presentation/pages/payment_page.dart';
import '../../features/registration/presentation/bindings/registration_binding.dart';
import '../../features/registration/presentation/pages/registration_page.dart';
import '../../features/reports/presentation/bindings/home_binding.dart';
import '../../features/reports/presentation/pages/daily_report_route_page.dart';
import '../../features/reports/presentation/pages/home_page.dart';
import '../../features/reports/presentation/pages/in_progress_services_page.dart';
import '../../features/reports/presentation/pages/monthly_report_route_page.dart';
import '../../features/service/presentation/bindings/novo_atendimento_binding.dart';
import '../../features/service/presentation/bindings/service_binding.dart';
import '../../features/service/presentation/pages/novo_atendimento_page.dart';
import '../../features/service/presentation/pages/service_page.dart';
import 'app_routes.dart';

ServiceStatus? _inProgressServicesStatusFromArguments() {
  final Object? raw = Get.arguments;
  if (raw == null) {
    return null;
  }
  if (raw is ServiceStatus) {
    return raw;
  }
  return null;
}

abstract class AppPages {
  static final List<GetPage<dynamic>> pages = <GetPage<dynamic>>[
    GetPage<void>(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      binding: LicenseBinding(),
    ),
    GetPage<void>(
      name: AppRoutes.blocked,
      page: () => const BlockedPage(),
      binding: LicenseBinding(),
    ),
    GetPage<void>(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),
    GetPage<void>(
      name: AppRoutes.dailyReport,
      page: () => const DailyReportRoutePage(),
      binding: HomeBinding(),
    ),
    GetPage<void>(
      name: AppRoutes.monthlyReport,
      page: () => const MonthlyReportRoutePage(),
      binding: HomeBinding(),
    ),
    GetPage<void>(
      name: AppRoutes.registration,
      page: () => const RegistrationPage(),
      binding: RegistrationBinding(),
    ),
    GetPage<void>(
      name: AppRoutes.novoAtendimento,
      page: () => const NovoAtendimentoPage(),
      binding: NovoAtendimentoBinding(),
    ),
    GetPage<void>(
      name: AppRoutes.inProgressServices,
      page: () {
        final ServiceStatus? status = _inProgressServicesStatusFromArguments();
        return InProgressServicesRoutePage(status: status);
      },
    ),
    GetPage<void>(
      name: '${AppRoutes.service}/:vehicleId',
      page: () => const ServicePage(),
      binding: ServiceBinding(),
    ),
    GetPage<void>(
      name: '${AppRoutes.payment}/:serviceId',
      page: () => const PaymentPage(),
      binding: PaymentBinding(),
    ),
  ];
}
