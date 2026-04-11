import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import 'package:lava_cash/core/domain/expense/entities/expense.dart';
import 'package:lava_cash/core/domain/expense/repositories/expense_repository.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  ExpenseRepositoryImpl({required SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;

  static const String _table = 'despesas';
  static const String _empresaRequiredMessage =
      'Nenhuma empresa vinculada ao usuário. Verifique licença ou cadastro da empresa.';

  static String _dateOnlyIso(DateTime d) {
    final DateTime local = DateTime(d.year, d.month, d.day);
    final String y = local.year.toString().padLeft(4, '0');
    final String m = local.month.toString().padLeft(2, '0');
    final String day = local.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  /// Same pattern as [RegistrationRepositoryImpl]: RLS-visible empresa row.
  Future<Either<Failure, String>> _empresaIdForCurrentUser() async {
    final SupabaseClient? client = _client;
    if (client == null) {
      return const Left(ServerFailure('Supabase not configured'));
    }
    try {
      final Map<String, dynamic>? row =
          await client
              .from('empresas')
              .select('id')
              .limit(1)
              .maybeSingle();
      if (row == null) {
        return const Left(ServerFailure(_empresaRequiredMessage));
      }
      final String? id = row['id']?.toString();
      if (id == null || id.isEmpty) {
        return const Left(ServerFailure(_empresaRequiredMessage));
      }
      return Right(id);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Expense>>> listInDateRange({
    required DateTime startInclusive,
    required DateTime endInclusive,
  }) async {
    if (_client == null) {
      return const Left(ServerFailure('Supabase not configured'));
    }
    try {
      final String start = _dateOnlyIso(startInclusive);
      final String end = _dateOnlyIso(endInclusive);
      final List<dynamic> rows =
          await _client
              .from(_table)
              .select()
              .gte('data_referencia', start)
              .lte('data_referencia', end)
              .order('data_referencia', ascending: false)
              .order('created_at', ascending: false);
      final List<Expense> list = rows
          .map(
            (dynamic e) =>
                ExpenseModel.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ).toDomain(),
          )
          .toList();
      return Right(list);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Expense>> create({
    required String descricao,
    required String categoria,
    required double valor,
    required DateTime dataReferencia,
  }) async {
    if (_client == null) {
      return const Left(ServerFailure('Supabase not configured'));
    }
    final Either<Failure, String> empresaEither =
        await _empresaIdForCurrentUser();
    if (empresaEither.isLeft()) {
      return Left<Failure, Expense>(
        empresaEither.fold((Failure f) => f, (_) => throw StateError('')),
      );
    }
    final String empresaId = empresaEither.getOrElse(() => '');
    if (empresaId.isEmpty) {
      return const Left(ServerFailure(_empresaRequiredMessage));
    }
    try {
      final Map<String, dynamic> row =
          await _client
              .from(_table)
              .insert(<String, dynamic>{
                'empresa_id': empresaId,
                'descricao': descricao.trim(),
                'categoria':
                    categoria.trim().isEmpty ? 'outros' : categoria.trim(),
                'valor': valor,
                'data_referencia': _dateOnlyIso(dataReferencia),
              })
              .select()
              .single();
      final Expense expense = ExpenseModel.fromJson(row).toDomain();
      return Right<Failure, Expense>(expense);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Expense>> update({
    required String id,
    required String descricao,
    required String categoria,
    required double valor,
  }) async {
    if (_client == null) {
      return const Left(ServerFailure('Supabase not configured'));
    }
    try {
      final Map<String, dynamic> row =
          await _client
              .from(_table)
              .update(<String, dynamic>{
                'descricao': descricao.trim(),
                'categoria':
                    categoria.trim().isEmpty ? 'outros' : categoria.trim(),
                'valor': valor,
                'updated_at': DateTime.now().toUtc().toIso8601String(),
              })
              .eq('id', id)
              .select()
              .single();
      final Expense expense = ExpenseModel.fromJson(row).toDomain();
      return Right<Failure, Expense>(expense);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> delete(String id) async {
    if (_client == null) {
      return const Left(ServerFailure('Supabase not configured'));
    }
    try {
      await _client.from(_table).delete().eq('id', id);
      return const Right(unit);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
