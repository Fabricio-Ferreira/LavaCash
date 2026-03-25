import '../controllers/report_controller.dart';

class DailyReportState {
  const DailyReportState({
    required this.totalRecebido,
    required this.totalCarros,
    required this.emAndamento,
    required this.paymentEntries,
    required this.isLoading,
  });

  final double totalRecebido;
  final int totalCarros;
  final int emAndamento;
  final List<MapEntry<String, double>> paymentEntries;
  final bool isLoading;

  static DailyReportState fromController(ReportController c) {
    if (c.isDailyLoading.value) {
      return const DailyReportState(
        totalRecebido: 0,
        totalCarros: 0,
        emAndamento: 0,
        paymentEntries: [],
        isLoading: true,
      );
    }
    final report = c.dailyReport.value;
    if (report == null) {
      return const DailyReportState(
        totalRecebido: 0,
        totalCarros: 0,
        emAndamento: 0,
        paymentEntries: [],
        isLoading: false,
      );
    }
    final List<MapEntry<String, double>> entries =
        report.totalPorFormaPagamento.entries.toList()..sort(
          (MapEntry<String, double> a, MapEntry<String, double> b) =>
              b.value.compareTo(a.value),
        );
    return DailyReportState(
      totalRecebido: report.totalRecebido,
      totalCarros: report.totalCarros,
      emAndamento: report.emAndamento,
      paymentEntries: entries,
      isLoading: false,
    );
  }
}
