import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../controllers/home_tab_controller.dart';
import '../controllers/report_controller.dart';
import '../widgets/home_top_bar.dart';
import '../widgets/stitch_bottom_nav.dart';
import 'dashboard_tab.dart';
import 'reports_tab.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeTabController tabs = Get.find<HomeTabController>();
    final ReportController reports = Get.find<ReportController>();
    return Obx(() {
      final int index = tabs.currentTab.value;
      return Scaffold(
        extendBody: true,
        backgroundColor: AppColors.surface,
        body: Column(
          children: [
            const HomeTopBar(),
            Expanded(
              child: IndexedStack(
                index: index,
                children: const [DashboardTab(), ReportsTab()],
              ),
            ),
          ],
        ),
        bottomNavigationBar: StitchBottomNav(
          currentIndex: index,
          onSelect: (int i) {
            if (i == 2) {
              Get.toNamed(AppRoutes.registration);
              return;
            }
            tabs.setTab(i);
            if (i == 0 || i == 1) {
              reports.loadDaily();
              reports.loadMonthly();
            }
          },
        ),
      );
    });
  }
}
