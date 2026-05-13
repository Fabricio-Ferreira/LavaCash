import 'package:lava_cash/core/domain/entities/attendance_service_line.dart';
import 'package:lava_cash/core/domain/entities/service_record.dart';
import 'package:lava_cash/core/utils/formatters.dart';

/// Stateless rules for totals and payment readiness (no framework deps).
abstract final class ServiceAttendancePricing {
  static double sumLines(Iterable<AttendanceServiceLine> lines) {
    return lines.fold<double>(
      0,
      (double a, AttendanceServiceLine l) => a + l.valor,
    );
  }

  static double resolveDisplayTotal({
    required List<AttendanceServiceLine> lines,
    required bool lineItemsDriveTotal,
    required ServiceRecord? record,
    required String valorFieldText,
  }) {
    if (lines.isNotEmpty) {
      return sumLines(lines);
    }
    if (lineItemsDriveTotal) {
      return AppFormatters.parseMoneyInput(valorFieldText) ?? 0;
    }
    final double? fromRecord = record?.valor;
    if (fromRecord != null && fromRecord > 0) {
      return fromRecord;
    }
    return AppFormatters.parseMoneyInput(valorFieldText) ?? 0;
  }

  static bool isPaymentFormSatisfied({
    required List<AttendanceServiceLine> lines,
    required String nomeFieldText,
    required String valorFieldText,
  }) {
    if (lines.isNotEmpty) {
      return sumLines(lines) > 0;
    }
    final bool hasNome = nomeFieldText.trim().isNotEmpty;
    final double? valor = AppFormatters.parseMoneyInput(valorFieldText);
    return hasNome && valor != null && valor > 0;
  }

  static String paymentServiceLabel({
    required List<AttendanceServiceLine> lines,
    required String nomeFieldText,
    required ServiceRecord record,
  }) {
    if (lines.isEmpty) {
      final String nomeTrim = nomeFieldText.trim();
      if (nomeTrim.isNotEmpty) {
        return nomeTrim;
      }
      return record.nomeServico ?? 'Serviço';
    }
    if (lines.length == 1) {
      return lines.first.nome;
    }
    return 'Múltiplos serviços';
  }
}
