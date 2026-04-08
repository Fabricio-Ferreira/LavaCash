import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/app_global_controller.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/home_top_bar.dart';
import '../../../app_update/presentation/controllers/app_update_controller.dart';
import '../bindings/home_binding.dart';
import '../controllers/home_tab_controller.dart';
import '../controllers/report_controller.dart';
import 'dashboard_tab.dart';
import 'reports_tab.dart';
import 'widgets/access_denied_reports_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
              final bool isAdmin =
                  Get.find<AppGlobalController>().userRole.value.isAdmin;
              return IndexedStack(
                index: tabIndex,
                children: <Widget>[
                  const DashboardTab(),
                  if (isAdmin) const ReportsTab() else const AccessDeniedReportsTab(),
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
            if (selectedIndex == 0 || selectedIndex == 1) {
              reports.refreshIfStaleForHomeTab();
            }
          },
        );
      }),
    );
  }
}
