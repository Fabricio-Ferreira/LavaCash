import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import 'package:lava_cash/core/domain/entities/attendance_history_line.dart';
import 'package:lava_cash/core/domain/entities/attendance_history_page_result.dart';
import 'package:lava_cash/core/domain/reports/attendance_history_range_validation.dart';
import 'package:lava_cash/core/domain/entities/best_weekday_report.dart';
import 'package:lava_cash/core/domain/entities/daily_report.dart';
import 'package:lava_cash/core/domain/entities/monthly_report.dart';
import 'package:lava_cash/core/domain/entities/service_status.dart';
import 'package:lava_cash/core/domain/entities/service_breakdown_row.dart';
import 'package:lava_cash/core/domain/entities/service_summary.dart';
import 'package:lava_cash/core/domain/entities/weekly_report.dart';
import 'package:lava_cash/core/domain/reports/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  ReportRepositoryImpl({required SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;

  @override
  Future<Either<Failure, DailyReport>> getDailyReport(DateTime day) async {
    if (_client == null) {
      return const Left(ServerFailure('Supabase not configured'));
    }
    try {
      final DateTime start = DateTime(day.year, day.month, day.day);
      final DateTime end = start.add(const Duration(days: 1));
      final String dataReferenciaKey = _dateKeyLocal(start);
      final List<dynamic> parallel =
          await Future.wait<dynamic>(<Future<dynamic>>[
            _client
                .from('atendimentos')
                .select('valor, forma_pagamento')
                .eq('status', 'finalizado')
                .gte('hora_entrada', start.toUtc().toIso8601String())
                .lt('hora_entrada', end.toUtc().toIso8601String()),
            _client
                .from('atendimentos')
                .select('id')
                .eq('status', 'em_andamento')
                .gte('hora_entrada', start.toUtc().toIso8601String())
                .lt('hora_entrada', end.toUtc().toIso8601String()),
            _client
                .from('despesas')
                .select('valor')
                .eq('data_referencia', dataReferenciaKey),
          ]);
      final List<dynamic> rows = parallel[0] as List<dynamic>;
      final List<dynamic> emAndamentoRows = parallel[1] as List<dynamic>;
      final List<dynamic> despesasRows = parallel[2] as List<dynamic>;
      final int emAndamento = emAndamentoRows.length;
      final Map<String, double> byForm = <String, double>{};
      double total = 0;
      int count = 0;
      for (final dynamic row in rows) {
        final Map<String, dynamic> map = row as Map<String, dynamic>;
        final String? forma = map['forma_pagamento'] as String?;
        final dynamic rawValor = map['valor'];
        final double? valor = _toDouble(rawValor);
        if (valor == null || forma == null) {
          continue;
        }
        count += 1;
        total += valor;
        byForm[forma] = (byForm[forma] ?? 0) + valor;
      }
      double totalDespesas = 0;
      for (final dynamic row in despesasRows) {
        final Map<String, dynamic> map = row as Map<String, dynamic>;
        final double? v = _toDouble(map['valor']);
        if (v != null) {
          totalDespesas += v;
        }
      }
      return Right(
        DailyReport(
          totalCarros: count,
          totalRecebido: total,
          totalDespesas: totalDespesas,
          totalPorFormaPagamento: byForm,
          emAndamento: emAndamento,
        ),
      );
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ServiceSummary>>> getTodayServices(
    DateTime day, {
    int? limit,
  }) async {
    if (_client == null) {
      return const Left(ServerFailure('Supabase not configured'));
    }
    try {
      final DateTime start = DateTime(day.year, day.month, day.day);
      final DateTime end = start.add(const Duration(days: 1));
      final int effectiveLimit = limit ?? 100;
      final List<dynamic> rows = await _client
          .from('atendimentos')
          .select(
            'id, veiculo_id, hora_entrada, valor, status, '
            'veiculos(placa, clientes(nome))',
          )
          .gte('hora_entrada', start.toUtc().toIso8601String())
          .lt('hora_entrada', end.toUtc().toIso8601String())
          .order('hora_entrada', ascending: false)
          .limit(effectiveLimit);
      final List<ServiceSummary> list = <ServiceSummary>[];
      for (final dynamic row in rows) {
        final ServiceSummary? item = _mapRowToServiceSummary(
          row as Map<String, dynamic>,
        );
        if (item != null) {
          list.add(item);
        }
      }
      return Right(list);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // @override
  // Future<Either<Failure, List<ServiceSummary>>> getInProgressServices() async {
  //   if (_client == null) {
  //     return const Left(ServerFailure('Supabase not configured'));
  //   }
  //   try {
  //     final List<dynamic> rows = await _client
  //         .from('atendimentos')
  //         .select(
  //           'id, hora_entrada, valor, status, '
  //           'veiculos(placa, clientes(nome))',
  //         )
  //         .eq('status', 'em_andamento')
  //         .order('hora_entrada', ascending: false);
  //     final List<ServiceSummary> list = <ServiceSummary>[];
  //     for (final dynamic row in rows) {
  //       final ServiceSummary? item = _mapRowToServiceSummary(
  //         row as Map<String, dynamic>,
  //       );
  //       if (item != null) {
  //         list.add(item);
  //       }
  //     }
  //     return Right(list);
  //   } on PostgrestException catch (e) {
  //     return Left(ServerFailure(e.message));
  //   } on Exception catch (e) {
  //     return Left(ServerFailure(e.toString()));
  //   }
  // }

  ServiceSummary? _mapRowToServiceSummary(Map<String, dynamic> map) {
    final String? id = map['id']?.toString();
    final String? veiculoId = map['veiculo_id']?.toString();
    final String? horaRaw = map['hora_entrada'] as String?;
    final String? statusRaw = map['status'] as String?;
    if (id == null ||
        veiculoId == null ||
        horaRaw == null ||
        statusRaw == null) {
      return null;
    }
    final ServiceStatus? status = ServiceStatusX.fromDb(statusRaw);
    if (status == null) {
      return null;
    }
    final DateTime horaEntrada = DateTime.parse(horaRaw).toLocal();
    String placa = '';
    String clienteNome = '';
    final dynamic veiculos = map['veiculos'];
    if (veiculos is Map<String, dynamic>) {
      placa = veiculos['placa'] as String? ?? '';
      final dynamic clientes = veiculos['clientes'];
      if (clientes is Map<String, dynamic>) {
        clienteNome = clientes['nome'] as String? ?? '';
      }
    }
    return ServiceSummary(
      id: id,
      veiculoId: veiculoId,
      clienteNome: clienteNome.isEmpty ? '—' : clienteNome,
      placa: placa.isEmpty ? '—' : placa,
      horaEntrada: horaEntrada,
      valor: _toDouble(map['valor']),
      status: status,
    );
  }

  @override
  Future<Either<Failure, List<MonthlyReport>>> getMonthlyReports() async {
    if (_client == null) {
      return const Left(ServerFailure('Supabase not configured'));
    }
    try {
      final List<dynamic> rows = await _client
          .from('atendimentos')
          .select('hora_entrada, valor')
          .eq('status', 'finalizado')
          .order('hora_entrada', ascending: false);
      final Map<String, _MonthAgg> agg = <String, _MonthAgg>{};
      for (final dynamic row in rows) {
        final Map<String, dynamic> map = row as Map<String, dynamic>;
        final DateTime entrada =
            DateTime.parse(map['hora_entrada'] as String).toLocal();
        final String key = '${entrada.year}-${entrada.month}';
        final double valor = _toDouble(map['valor']) ?? 0;
        final _MonthAgg current =
            agg[key] ?? _MonthAgg(mes: DateTime(entrada.year, entrada.month));
        current.totalAtendimentos += 1;
        current.faturamento += valor;
        agg[key] = current;
      }
      final List<MonthlyReport> list =
          agg.values
              .map(
                (final _MonthAgg a) => MonthlyReport(
                  mes: a.mes,
                  totalAtendimentos: a.totalAtendimentos,
                  faturamento: a.faturamento,
                ),
              )
              .toList();
      list.sort(
        (final MonthlyReport a, final MonthlyReport b) =>
            b.mes.compareTo(a.mes),
      );
      return Right(list);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WeeklyReport>>> getWeeklyReport(
    DateTime month,
  ) async {
    if (_client == null) {
      return const Left(ServerFailure('Supabase not configured'));
    }
    try {
      final DateTime anchor = DateTime(month.year, month.month);
      final List<dynamic> rows = await _client.rpc(
        'get_weekly_report',
        params: <String, dynamic>{
          'p_year': anchor.year,
          'p_month': anchor.month,
        },
      );
      final Map<int, WeeklyReport> byWeek = <int, WeeklyReport>{};
      for (final dynamic row in rows) {
        final Map<String, dynamic> map = row as Map<String, dynamic>;
        final int? semana = _toInt(map['semana']);
        if (semana == null || semana < 1 || semana > 4) {
          continue;
        }
        byWeek[semana] = WeeklyReport(
          semana: semana,
          totalAtendimentos: _toInt(map['total_atendimentos']) ?? 0,
          faturamento: _toDouble(map['faturamento']) ?? 0,
        );
      }
      final List<WeeklyReport> filled = List<WeeklyReport>.generate(4, (int i) {
        final int semana = i + 1;
        return byWeek[semana] ??
            WeeklyReport(semana: semana, totalAtendimentos: 0, faturamento: 0);
      });
      return Right(filled);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BestWeekdayReport?>> getBestWeekdayReport(
    DateTime month,
  ) async {
    if (_client == null) {
      return const Left(ServerFailure('Supabase not configured'));
    }
    try {
      final DateTime anchor = DateTime(month.year, month.month);
      final List<dynamic> rows = await _client.rpc(
        'get_best_weekday_report',
        params: <String, dynamic>{
          'p_year': anchor.year,
          'p_month': anchor.month,
        },
      );
      if (rows.isEmpty) {
        return const Right(null);
      }
      final Map<String, dynamic> map = rows.first as Map<String, dynamic>;
      final String? dia = map['dia_semana'] as String?;
      if (dia == null) {
        return const Right(null);
      }
      return Right(
        BestWeekdayReport(
          diaSemana: dia,
          faturamento: _toDouble(map['faturamento']) ?? 0,
        ),
      );
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  static String _pdfDateIso(DateTime d) {
    final String y = d.year.toString().padLeft(4, '0');
    final String m = d.month.toString().padLeft(2, '0');
    final String day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  static String _pdfMesRefIso(DateTime m) {
    final String y = m.year.toString().padLeft(4, '0');
    final String mo = m.month.toString().padLeft(2, '0');
    return '$y-$mo';
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getPdfDailySummary(
    DateTime day,
  ) async {
    if (_client == null) {
      return const Left(ServerFailure('Supabase not configured'));
    }
    try {
      final String dr = _pdfDateIso(day);
      final Map<String, dynamic>? row =
          await _client
              .from('vw_relatorio_diario_pdf')
              .select()
              .eq('data_ref', dr)
              .maybeSingle();
      return Right(_normalizePdfSummaryRow(row));
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>>
  getPdfDailyAttendanceRows(DateTime day) async {
    if (_client == null) {
      return const Left(ServerFailure('Supabase not configured'));
    }
    try {
      final String dr = _pdfDateIso(day);
      final List<dynamic> rows =
          await _client
              .from('vw_relatorio_diario_atendimentos_detalhe')
              .select()
              .eq('data_ref', dr)
              .order('hora_entrada_local', ascending: false);
      final List<Map<String, dynamic>> list = rows
          .map((dynamic e) => Map<String, dynamic>.from(e as Map))
          .toList();
      return Right(list);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getPdfDailyExpenseRows(
    DateTime day,
  ) async {
    if (_client == null) {
      return const Left(ServerFailure('Supabase not configured'));
    }
    try {
      final String dr = _pdfDateIso(day);
      final List<dynamic> rows =
          await _client
              .from('vw_relatorio_diario_despesas_detalhe')
              .select()
              .eq('data_ref', dr)
              .order('registrado_em', ascending: false);
      final List<Map<String, dynamic>> list = rows
          .map((dynamic e) => Map<String, dynamic>.from(e as Map))
          .toList();
      return Right(list);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  static const int _maxIntervalDays = 366;

  @override
  Future<Either<Failure, Map<String, dynamic>>> getIntervalSummary(
    DateTime startInclusive,
    DateTime endInclusive,
  ) async {
    if (_client == null) {
      return const Left(ServerFailure('Supabase not configured'));
    }
    try {
      final DateTime start = DateTime(
        startInclusive.year,
        startInclusive.month,
        startInclusive.day,
      );
      final DateTime end = DateTime(
        endInclusive.year,
        endInclusive.month,
        endInclusive.day,
      );
      if (start.isAfter(end)) {
        return const Left(ValidationFailure('Data inicial após a data final'));
      }
      final int spanDays = end.difference(start).inDays + 1;
      if (spanDays > _maxIntervalDays) {
        return Left(
          ValidationFailure('Período máximo: $_maxIntervalDays dias'),
        );
      }
      final DateTime endExclusive = end.add(const Duration(days: 1));
      final List<dynamic> parallel =
          await Future.wait<dynamic>(<Future<dynamic>>[
            _client
                .from('atendimentos')
                .select('valor, forma_pagamento')
                .eq('status', 'finalizado')
                .gte('hora_entrada', start.toUtc().toIso8601String())
                .lt(
                  'hora_entrada',
                  endExclusive.toUtc().toIso8601String(),
                ),
            _client
                .from('despesas')
                .select('valor')
                .gte('data_referencia', _pdfDateIso(start))
                .lte('data_referencia', _pdfDateIso(end)),
          ]);
      final List<dynamic> attRows = parallel[0] as List<dynamic>;
      final List<dynamic> expRows = parallel[1] as List<dynamic>;
      double totalEntradas = 0;
      int count = 0;
      double totalDinheiro = 0;
      double totalPix = 0;
      double totalDebito = 0;
      double totalCredito = 0;
      double totalLink = 0;
      for (final dynamic row in attRows) {
        final Map<String, dynamic> map = row as Map<String, dynamic>;
        final String? forma = map['forma_pagamento'] as String?;
        final double? valor = _toDouble(map['valor']);
        if (valor == null || forma == null) {
          continue;
        }
        count += 1;
        totalEntradas += valor;
        switch (forma) {
          case 'dinheiro':
            totalDinheiro += valor;
            break;
          case 'pix':
            totalPix += valor;
            break;
          case 'debito':
            totalDebito += valor;
            break;
          case 'credito':
            totalCredito += valor;
            break;
          case 'link':
            totalLink += valor;
            break;
          default:
            break;
        }
      }
      double totalSaidas = 0;
      for (final dynamic row in expRows) {
        final Map<String, dynamic> map = row as Map<String, dynamic>;
        totalSaidas += _toDouble(map['valor']) ?? 0;
      }
      final double ticketMedio = count > 0 ? totalEntradas / count : 0;
      final Map<String, dynamic> summary = <String, dynamic>{
        'total_entradas': totalEntradas,
        'total_saidas': totalSaidas,
        'saldo_liquido': totalEntradas - totalSaidas,
        'ticket_medio': ticketMedio,
        'total_lavagens': count,
        'total_dinheiro': totalDinheiro,
        'total_pix': totalPix,
        'total_debito': totalDebito,
        'total_credito': totalCredito,
        'total_link': totalLink,
      };
      return Right(summary);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>>
  getIntervalAttendanceRows(
    DateTime startInclusive,
    DateTime endInclusive,
  ) async {
    if (_client == null) {
      return const Left(ServerFailure('Supabase not configured'));
    }
    try {
      final DateTime start = DateTime(
        startInclusive.year,
        startInclusive.month,
        startInclusive.day,
      );
      final DateTime end = DateTime(
        endInclusive.year,
        endInclusive.month,
        endInclusive.day,
      );
      if (start.isAfter(end)) {
        return const Left(ValidationFailure('Data inicial após a data final'));
      }
      final int spanDays = end.difference(start).inDays + 1;
      if (spanDays > _maxIntervalDays) {
        return Left(
          ValidationFailure('Período máximo: $_maxIntervalDays dias'),
        );
      }
      final String s = _pdfDateIso(start);
      final String e = _pdfDateIso(end);
      final List<dynamic> rows =
          await _client
              .from('vw_relatorio_diario_atendimentos_detalhe')
              .select()
              .gte('data_ref', s)
              .lte('data_ref', e)
              .order('hora_entrada_local', ascending: false);
      final List<Map<String, dynamic>> list = rows
          .map((dynamic r) => Map<String, dynamic>.from(r as Map))
          .toList();
      return Right(list);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getIntervalExpenseRows(
    DateTime startInclusive,
    DateTime endInclusive,
  ) async {
    if (_client == null) {
      return const Left(ServerFailure('Supabase not configured'));
    }
    try {
      final DateTime start = DateTime(
        startInclusive.year,
        startInclusive.month,
        startInclusive.day,
      );
      final DateTime end = DateTime(
        endInclusive.year,
        endInclusive.month,
        endInclusive.day,
      );
      if (start.isAfter(end)) {
        return const Left(ValidationFailure('Data inicial após a data final'));
      }
      final int spanDays = end.difference(start).inDays + 1;
      if (spanDays > _maxIntervalDays) {
        return Left(
          ValidationFailure('Período máximo: $_maxIntervalDays dias'),
        );
      }
      final String s = _pdfDateIso(start);
      final String e = _pdfDateIso(end);
      final List<dynamic> rows =
          await _client
              .from('vw_relatorio_diario_despesas_detalhe')
              .select()
              .gte('data_ref', s)
              .lte('data_ref', e)
              .order('registrado_em', ascending: false);
      final List<Map<String, dynamic>> list = rows
          .map((dynamic r) => Map<String, dynamic>.from(r as Map))
          .toList();
      return Right(list);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getPdfMonthlySummary(
    DateTime month,
  ) async {
    if (_client == null) {
      return const Left(ServerFailure('Supabase not configured'));
    }
    try {
      final String mr = _pdfMesRefIso(month);
      final Map<String, dynamic>? row =
          await _client
              .from('vw_relatorio_mensal_pdf')
              .select()
              .eq('mes_ref', mr)
              .maybeSingle();
      return Right(_normalizePdfSummaryRow(row));
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  static Map<String, dynamic> _normalizePdfSummaryRow(
    Map<String, dynamic>? row,
  ) {
    final Map<String, dynamic> m = row ?? <String, dynamic>{};
    double v(String k) {
      final Object? o = m[k];
      if (o == null) {
        return 0;
      }
      if (o is num) {
        return o.toDouble();
      }
      return double.tryParse(o.toString()) ?? 0;
    }

    int i(String k) {
      final Object? o = m[k];
      if (o == null) {
        return 0;
      }
      if (o is int) {
        return o;
      }
      if (o is num) {
        return o.toInt();
      }
      return int.tryParse(o.toString()) ?? 0;
    }

    return <String, dynamic>{
      'total_entradas': v('total_entradas'),
      'total_saidas': v('total_saidas'),
      'saldo_liquido': v('saldo_liquido'),
      'ticket_medio': v('ticket_medio'),
      'total_lavagens': i('total_lavagens'),
      'total_dinheiro': v('total_dinheiro'),
      'total_pix': v('total_pix'),
      'total_debito': v('total_debito'),
      'total_credito': v('total_credito'),
      'total_link': v('total_link'),
    };
  }

  int? _toInt(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value.toString());
  }

  double? _toDouble(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString());
  }

  /// `YYYY-MM-DD` for [data_referencia] (DATE) filters, local calendar day.
  String _dateKeyLocal(DateTime day) {
    final DateTime local = DateTime(day.year, day.month, day.day);
    final String y = local.year.toString().padLeft(4, '0');
    final String m = local.month.toString().padLeft(2, '0');
    final String d = local.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  @override
  Future<Either<Failure, AttendanceHistoryPageResult>> getAttendanceHistory({
    required DateTime startInclusive,
    required DateTime endInclusive,
    String? query,
    int vehicleLimit = 10,
    int vehicleOffset = 0,
    bool fetchAllVehicles = false,
  }) async {
    if (_client == null) {
      return const Left(ServerFailure('Supabase not configured'));
    }
    try {
      final String? rangeError = AttendanceHistoryRangeValidation.validate(
        startInclusive,
        endInclusive,
      );
      if (rangeError != null) {
        return Left(ValidationFailure(rangeError));
      }
      final DateTime start = DateTime(
        startInclusive.year,
        startInclusive.month,
        startInclusive.day,
      );
      final DateTime end = DateTime(
        endInclusive.year,
        endInclusive.month,
        endInclusive.day,
      );
      final String startKey = _dateKeyLocal(start);
      final String endKey = _dateKeyLocal(end);
      final dynamic rawRows = await _client.rpc(
        'get_attendance_history',
        params: <String, dynamic>{
          'p_start_date': startKey,
          'p_end_date': endKey,
          'p_query': query?.trim() ?? '',
          'p_vehicle_limit': vehicleLimit,
          'p_vehicle_offset': vehicleOffset,
          'p_fetch_all_vehicles': fetchAllVehicles,
        },
      );
      if (rawRows == null) {
        return Right(
          AttendanceHistoryPageResult(
            lines: <AttendanceHistoryLine>[],
            totalVehicles: vehicleOffset == 0 ? 0 : null,
          ),
        );
      }
      if (rawRows is! List<dynamic>) {
        return const Left(
          ServerFailure('Resposta inválida do histórico de atendimentos'),
        );
      }
      if (rawRows.isEmpty) {
        return Right(
          AttendanceHistoryPageResult(
            lines: <AttendanceHistoryLine>[],
            totalVehicles: vehicleOffset == 0 ? 0 : null,
          ),
        );
      }
      final List<AttendanceHistoryLine> list = <AttendanceHistoryLine>[];
      int? totalVehicles;
      for (int i = 0; i < rawRows.length; i++) {
        final dynamic row = rawRows[i];
        if (row is! Map) {
          continue;
        }
        final Map<String, dynamic> map = Map<String, dynamic>.from(row);
        totalVehicles ??= _toInt(map['total_veiculos']);
        final AttendanceHistoryLine? line = _mapAttendanceHistoryRow(map);
        if (line != null) {
          list.add(line);
        }
      }
      return Right(
        AttendanceHistoryPageResult(
          lines: list,
          totalVehicles: totalVehicles,
        ),
      );
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  AttendanceHistoryLine? _mapAttendanceHistoryRow(Map<String, dynamic> map) {
    final String? atId = map['atendimento_id']?.toString();
    final String? vId = map['veiculo_id']?.toString();
    final String? placa = map['placa'] as String?;
    final String? nome = map['cliente_nome'] as String?;
    final Object? horaRaw = map['hora_entrada_local'];
    if (atId == null || vId == null || placa == null || nome == null) {
      return null;
    }
    final String? horaStr = horaRaw?.toString();
    if (horaStr == null || horaStr.isEmpty) {
      return null;
    }
    final DateTime? hora = DateTime.tryParse(horaStr);
    if (hora == null) {
      return null;
    }
    return AttendanceHistoryLine(
      atendimentoId: atId,
      veiculoId: vId,
      placa: placa,
      clienteNome: nome,
      horaEntradaLocal: hora,
      valor: _toDouble(map['valor']),
      formaPagamento: map['forma_pagamento'] as String?,
    );
  }

  @override
  Future<Either<Failure, List<ServiceBreakdownRow>>> getServiceBreakdown(
    DateTime startInclusive,
    DateTime endInclusive,
  ) async {
    if (_client == null) {
      return const Left(ServerFailure('Supabase not configured'));
    }
    try {
      final DateTime start = DateTime(
        startInclusive.year,
        startInclusive.month,
        startInclusive.day,
      );
      final DateTime end = DateTime(
        endInclusive.year,
        endInclusive.month,
        endInclusive.day,
      );
      final String pStart = _dateKeyLocal(start);
      final String pEnd = _dateKeyLocal(end);
      final dynamic raw = await _client.rpc(
        'get_service_breakdown_report',
        params: <String, dynamic>{
          'p_start': pStart,
          'p_end': pEnd,
        },
      );
      if (raw is! List<dynamic>) {
        return const Left(
          ServerFailure('Resposta inválida do relatório por serviço'),
        );
      }
      final List<ServiceBreakdownRow> out = <ServiceBreakdownRow>[];
      for (final dynamic row in raw) {
        if (row is! Map) {
          continue;
        }
        final Map<String, dynamic> map = Map<String, dynamic>.from(row);
        final String nome = map['nome_exibicao'] as String? ?? '';
        final int q = _toInt(map['quantidade']) ?? 0;
        final double f = _toDouble(map['faturamento']) ?? 0;
        out.add(
          ServiceBreakdownRow(
            nomeExibicao: nome,
            quantidade: q,
            faturamento: f,
          ),
        );
      }
      return Right(out);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

class _MonthAgg {
  _MonthAgg({required this.mes});

  final DateTime mes;
  int totalAtendimentos = 0;
  double faturamento = 0;
}
