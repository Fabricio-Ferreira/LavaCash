import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/home_top_bar.dart';
import 'package:lava_cash/features/service_catalog/presentation/pages/services_catalog_tab.dart';
import 'package:lava_cash/features/app_update/presentation/controllers/app_update_controller.dart';
import 'package:lava_cash/features/reports/presentation/controllers/report_controller.dart';
import 'package:lava_cash/features/reports/presentation/pages/reports_tab.dart';
import '../../bindings/home_binding.dart';
import '../controllers/home_tab_controller.dart';
import 'dashboard_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Bottom bar: 0 home, 1 reports, 2 atendimento (route), 3 services catalog.
  /// [IndexedStack] only has [DashboardTab], [ReportsTab], [ServicesCatalogTab].
  static int _stackIndexForTab(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return 0;
      case 1:
        return 1;
      case 3:
        return 2;
      default:
        return 0;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<AppUpdateController>()) {
        Get.find<AppUpdateController>();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final HomeTabController tabs = Get.find<HomeTabController>();
    final ReportController reports = Get.find<ReportController>();
    HomeBinding.ensureDashboardController();
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.surface,
      body: Column(
        children: <Widget>[
          const HomeTopBar(),
          Expanded(
            child: Obx(() {
              final int tabIndex = tabs.currentTab.value;
              return IndexedStack(
                index: _stackIndexForTab(tabIndex),
                children: const <Widget>[
                  DashboardTab(),
                  ReportsTab(),
                  ServicesCatalogTab(),
                ],
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: Obx(() {
        final int tabIndex = tabs.currentTab.value;
        return AppBottomNavigation(
          currentIndex: tabIndex,
          onSelect: (int selectedIndex) {
            if (selectedIndex == 2) {
              Get.toNamed(AppRoutes.novoAtendimento);
              return;
            }
            tabs.setTab(selectedIndex);
            if (selectedIndex == 0) {
              reports.resetSelectionsToTodayAndThisMonth();
            } else if (selectedIndex == 1) {
              reports.refreshIfStaleForHomeTab();
            }
          },
        );
      }),
    );
  }
}
