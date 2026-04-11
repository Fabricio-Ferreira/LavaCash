import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/interval_report_controller.dart';
import 'interval_report_tab.dart';

/// Tela cheia: relatório por intervalo.
///
/// Opcional: [Get.arguments] como `Map` com `start` e `end` [DateTime]
/// (datas inclusivas, calendário local).
class IntervalReportRoutePage extends StatefulWidget {
  const IntervalReportRoutePage({super.key});

  @override
  State<IntervalReportRoutePage> createState() =>
      _IntervalReportRoutePageState();
}

class _IntervalReportRoutePageState extends State<IntervalReportRoutePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Object? raw = Get.arguments;
      if (raw is Map) {
        final DateTime? s = raw['start'] as DateTime?;
        final DateTime? e = raw['end'] as DateTime?;
        if (s != null && e != null) {
          Get.find<IntervalReportController>().setRange(s, e);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final IntervalReportController c = Get.find<IntervalReportController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatório por período'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Exportar PDF',
            onPressed: c.exportPdf,
          ),
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Imprimir',
            onPressed: c.printPdf,
          ),
        ],
      ),
      body: const IntervalReportTab(),
    );
  }
}
