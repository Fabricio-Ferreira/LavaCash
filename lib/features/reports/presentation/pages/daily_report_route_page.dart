import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/report_controller.dart';
import 'daily_report_tab.dart';

/// Full-screen daily report. Optional [Get.arguments]: [DateTime] for the day.
class DailyReportRoutePage extends StatefulWidget {
  const DailyReportRoutePage({super.key});

  @override
  State<DailyReportRoutePage> createState() => _DailyReportRoutePageState();
}

class _DailyReportRoutePageState extends State<DailyReportRoutePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Object? raw = Get.arguments;
      if (raw is DateTime) {
        Get.find<ReportController>().setDailyReportDay(raw);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ReportController reports = Get.find<ReportController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatório diário'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Exportar PDF',
            onPressed: reports.exportDailyPdf,
          ),
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Imprimir',
            onPressed: reports.printDailyPdf,
          ),
        ],
      ),
      body: const DailyReportTab(),
    );
  }
}
