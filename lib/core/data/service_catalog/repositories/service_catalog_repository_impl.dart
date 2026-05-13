import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import 'package:lava_cash/core/domain/entities/service_catalog_item.dart';
import 'package:lava_cash/core/domain/service_catalog/repositories/service_catalog_repository.dart';

class ServiceCatalogRepositoryImpl implements ServiceCatalogRepository {
  ServiceCatalogRepositoryImpl({required SupabaseClient? client})
    : _client = client;

  final SupabaseClient? _client;

  static const String _tableCatalog = 'servicos_catalogo';
  static const String _tableEmpresas = 'empresas';
  static const String _empresaRequiredMessage =
      'Nenhuma empresa vinculada ao usuário. Verifique licença ou cadastro da empresa.';
  static const ServerFailure _supabaseNotConfigured =
      ServerFailure('Supabase not configured');

  @override
  Future<Either<Failure, List<ServiceCatalogItem>>> listActiveCatalog() async {
    return _withClient((SupabaseClient client) async {
      try {
        final List<dynamic> rows =
            await client
                .from(_tableCatalog)
                .select()
                .eq('is_deleted', false)
                .order('nome', ascending: true);
        return Right(_mapRowsToItems(rows));
      } on PostgrestException catch (e) {
        return Left(ServerFailure(e.message));
      } on Exception catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    });
  }

  @override
  Future<Either<Failure, List<ServiceCatalogItem>>> listMaisUtilizados() async {
    return _withClient((SupabaseClient client) async {
      try {
        final List<dynamic> rows =
            await client
                .from(_tableCatalog)
                .select()
                .eq('is_deleted', false)
                .eq('is_mais_utilizado', true)
                .order('updated_at', ascending: false)
                .limit(3);
        return Right(_mapRowsToItems(rows));
      } on PostgrestException catch (e) {
        return Left(ServerFailure(e.message));
      } on Exception catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    });
  }

  @override
  Future<Either<Failure, ServiceCatalogItem>> createItem({
    required String nome,
    required double valorPadrao,
    String? observacao,
    required bool isMaisUtilizado,
  }) async {
    return _withTenant((SupabaseClient client, String empresaId) async {
      try {
        if (isMaisUtilizado) {
          final Either<Failure, Unit> guard = await _guardMaisUtilizadoLimit(
            client,
            excludeId: null,
          );
          final Failure? fail = guard.fold((Failure f) => f, (_) => null);
          if (fail != null) {
            return Left(fail);
          }
        }
        final Map<String, dynamic> row =
            await client
                .from(_tableCatalog)
                .insert(<String, dynamic>{
                  'empresa_id': empresaId,
                  ..._payloadForUpsert(
                    nome: nome,
                    valorPadrao: valorPadrao,
                    observacao: observacao,
                    isMaisUtilizado: isMaisUtilizado,
                  ),
                })
                .select()
                .single();
        return Right(_itemFromRow(row));
      } on PostgrestException catch (e) {
        return Left(_mapMutationFailure(e));
      } on Exception catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    });
  }

  @override
  Future<Either<Failure, ServiceCatalogItem>> updateItem({
    required String id,
    required String nome,
    required double valorPadrao,
    String? observacao,
    required bool isMaisUtilizado,
  }) async {
    return _withTenant((SupabaseClient client, String empresaId) async {
      try {
        if (isMaisUtilizado) {
          final Either<Failure, Unit> guard = await _guardMaisUtilizadoLimit(
            client,
            excludeId: id,
          );
          final Failure? fail = guard.fold((Failure f) => f, (_) => null);
          if (fail != null) {
            return Left(fail);
          }
        }
        final Map<String, dynamic> row =
            await client
                .from(_tableCatalog)
                .update(
                  _payloadForUpsert(
                    nome: nome,
                    valorPadrao: valorPadrao,
                    observacao: observacao,
                    isMaisUtilizado: isMaisUtilizado,
                  ),
                )
                .eq('id', id)
                .eq('empresa_id', empresaId)
                .eq('is_deleted', false)
                .select()
                .single();
        return Right(_itemFromRow(row));
      } on PostgrestException catch (e) {
        return Left(_mapMutationFailure(e));
      } on Exception catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    });
  }

  @override
  Future<Either<Failure, Unit>> softDeleteItem(String id) async {
    return _withTenant((SupabaseClient client, String empresaId) async {
      try {
        await client
            .from(_tableCatalog)
            .update(<String, dynamic>{
              'is_deleted': true,
              'is_mais_utilizado': false,
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            })
            .eq('id', id)
            .eq('empresa_id', empresaId);
        return const Right(unit);
      } on PostgrestException catch (e) {
        return Left(ServerFailure(e.message));
      } on Exception catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    });
  }

  Future<Either<Failure, T>> _withClient<T>(
    Future<Either<Failure, T>> Function(SupabaseClient client) run,
  ) async {
    final SupabaseClient? client = _client;
    if (client == null) {
      return const Left(_supabaseNotConfigured);
    }
    return run(client);
  }

  Future<Either<Failure, T>> _withTenant<T>(
    Future<Either<Failure, T>> Function(
      SupabaseClient client,
      String empresaId,
    ) run,
  ) async {
    return _withClient((SupabaseClient client) async {
      final Either<Failure, String> empresaResult =
          await _fetchEmpresaIdForSession(client);
      return empresaResult.fold(
        (Failure failure) async => Left<Failure, T>(failure),
        (String empresaId) => run(client, empresaId),
      );
    });
  }

  Future<Either<Failure, String>> _fetchEmpresaIdForSession(
    SupabaseClient client,
  ) async {
    try {
      final Map<String, dynamic>? row =
          await client
              .from(_tableEmpresas)
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

  Future<Either<Failure, Unit>> _guardMaisUtilizadoLimit(
    SupabaseClient client, {
    required String? excludeId,
  }) async {
    PostgrestFilterBuilder<List<dynamic>> filter = client
        .from(_tableCatalog)
        .select('id')
        .eq('is_deleted', false)
        .eq('is_mais_utilizado', true);
    if (excludeId != null) {
      filter = filter.neq('id', excludeId);
    }
    try {
      final List<dynamic> rows = await filter;
      if (rows.length >= 3) {
        return const Left(
          ValidationFailure(
            'Já existem 3 serviços em sugestões rápidas. '
            'Desmarque um antes de marcar outro.',
          ),
        );
      }
      return const Right(unit);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Failure _mapMutationFailure(PostgrestException e) {
    final String msg = e.message;
    if (msg.contains('Máximo de 3 serviços')) {
      return ValidationFailure(msg);
    }
    return ServerFailure(msg);
  }

  Map<String, dynamic> _payloadForUpsert({
    required String nome,
    required double valorPadrao,
    String? observacao,
    required bool isMaisUtilizado,
  }) {
    return <String, dynamic>{
      'nome': nome.trim(),
      'valor_padrao': valorPadrao,
      'observacao': _normalizedObservacao(observacao),
      'is_mais_utilizado': isMaisUtilizado,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }

  String? _normalizedObservacao(String? observacao) {
    if (observacao == null) {
      return null;
    }
    if (observacao.trim().isEmpty) {
      return null;
    }
    return observacao.trim();
  }

  List<ServiceCatalogItem> _mapRowsToItems(List<dynamic> rows) {
    return rows
        .map(
          (dynamic e) => _itemFromRow(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }

  ServiceCatalogItem _itemFromRow(Map<String, dynamic> row) {
    return ServiceCatalogItem(
      id: row['id'] as String,
      nome: row['nome'] as String,
      valorPadrao: _toDouble(row['valor_padrao']) ?? 0,
      observacao: row['observacao'] as String?,
      isMaisUtilizado: row['is_mais_utilizado'] as bool? ?? false,
      isDeleted: row['is_deleted'] as bool? ?? false,
    );
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
