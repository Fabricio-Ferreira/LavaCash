import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../../../domain/entities/daily_report.dart';
import '../../../../domain/entities/monthly_report.dart';
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
      final List<dynamic> rows = await _client
          .from('atendimentos')
          .select('valor, forma_pagamento')
          .eq('status', 'finalizado')
          .gte('hora_entrada', start.toUtc().toIso8601String())
          .lt('hora_entrada', end.toUtc().toIso8601String());
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
        ),
      );
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
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
        final _MonthAgg current = agg[key] ?? _MonthAgg(
          mes: DateTime(entrada.year, entrada.month),
        );
        current.totalAtendimentos += 1;
        current.faturamento += valor;
        agg[key] = current;
      }
      final List<MonthlyReport> list = agg.values
          .map(
            (final _MonthAgg a) => MonthlyReport(
              mes: a.mes,
              totalAtendimentos: a.totalAtendimentos,
              faturamento: a.faturamento,
            ),
          )
          .toList();
      list.sort((final MonthlyReport a, final MonthlyReport b) =>
          b.mes.compareTo(a.mes));
      return Right(list);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
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
