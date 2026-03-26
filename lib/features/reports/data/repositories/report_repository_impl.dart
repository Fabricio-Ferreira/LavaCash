import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../../../domain/entities/best_weekday_report.dart';
import '../../../../domain/entities/daily_report.dart';
import '../../../../domain/entities/monthly_report.dart';
import '../../../../domain/entities/service_status.dart';
import '../../../../domain/entities/service_summary.dart';
import '../../../../domain/entities/weekly_report.dart';
import '../../domain/repositories/report_repository.dart';

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
          ]);
      final List<dynamic> rows = parallel[0] as List<dynamic>;
      final List<dynamic> emAndamentoRows = parallel[1] as List<dynamic>;
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
      return Right(
        DailyReport(
          totalCarros: count,
          totalRecebido: total,
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
}

class _MonthAgg {
  _MonthAgg({required this.mes});

  final DateTime mes;
  int totalAtendimentos = 0;
  double faturamento = 0;
}
