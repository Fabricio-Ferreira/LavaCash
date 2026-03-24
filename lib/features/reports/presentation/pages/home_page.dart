import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../search/presentation/widgets/search_tab_body.dart';
import '../controllers/home_tab_controller.dart';
import '../controllers/report_controller.dart';
import 'daily_report_tab.dart';
import 'monthly_report_tab.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeTabController tabs = Get.find<HomeTabController>();
    final ReportController reports = Get.find<ReportController>();
    return Obx(
      () {
        final int index = tabs.currentTab.value;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Lava Cash'),
          ),
          body: IndexedStack(
            index: index,
            children: const [
              SearchTabBody(),
              DailyReportTab(),
              MonthlyReportTab(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: index,
            onTap: (int i) {
              tabs.setTab(i);
              if (i == 1) {
                reports.loadDaily();
              }
              if (i == 2) {
                reports.loadMonthly();
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Busca',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.today),
                label: 'Diário',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month),
                label: 'Mensal',
              ),
            ],
          ),
        );
      },
    );
  }
}
