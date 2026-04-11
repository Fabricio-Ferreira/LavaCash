import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/report_controller.dart';
import 'monthly_report_tab.dart';

/// Full-screen monthly report. Optional [Get.arguments]: [DateTime] — any day
/// in the target month (year + month are used).
class MonthlyReportRoutePage extends StatefulWidget {
  const MonthlyReportRoutePage({super.key});

  @override
  State<MonthlyReportRoutePage> createState() => _MonthlyReportRoutePageState();
}

class _MonthlyReportRoutePageState extends State<MonthlyReportRoutePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Object? raw = Get.arguments;
      if (raw is DateTime) {
        Get.find<ReportController>().setMonthlyReportMonth(raw);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ReportController reports = Get.find<ReportController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatório mensal'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Exportar PDF',
            onPressed: reports.exportMonthlyPdf,
          ),
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Imprimir',
            onPressed: reports.printMonthlyPdf,
          ),
        ],
      ),
      body: const MonthlyReportTab(),
    );
  }
}
