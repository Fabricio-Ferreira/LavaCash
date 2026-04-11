import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import 'package:lava_cash/core/domain/empresa/entities/empresa.dart';
import 'package:lava_cash/core/domain/empresa/repositories/empresa_repository.dart';
import '../models/empresa_model.dart';

class EmpresaRepositoryImpl implements EmpresaRepository {
  EmpresaRepositoryImpl({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;

  static const String _table = 'empresas';
  static const String _claimRpc = 'claim_empresa';

  /// One row: current user's empresa (RLS scopes the query).
  static const int _ownEmpresaRowLimit = 1;

  @override
  Future<Either<Failure, Empresa?>> fetchOwn() async {
    final SupabaseClient? client = _client;
    if (client == null) return const Right(null);
    try {
      final List<dynamic> data = await client
          .from(_table)
          .select()
          .limit(_ownEmpresaRowLimit);
      if (data.isEmpty) return const Right(null);
      final EmpresaModel model = EmpresaModel.fromJson(
        Map<String, dynamic>.from(data.first as Map),
      );
      return Right(model.toDomain());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Empresa?>> claimByActivationCode(
    String activationCode,
  ) async {
    final SupabaseClient? client = _client;
    if (client == null || activationCode.isEmpty) return const Right(null);
    try {
      final dynamic result = await client.rpc(
        _claimRpc,
        params: <String, dynamic>{'p_activation_code': activationCode},
      );
      // Retorna NULL se já reivindicada ou código inválido
      if (result == null) return const Right(null);
      // Sucesso — busca a empresa recém vinculada
      return fetchOwn();
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Empresa>> create({
    required String nome,
    required String telefone,
    required String activationCode,
  }) async {
    final SupabaseClient? client = _client;
    if (client == null) {
      return const Left(ServerFailure('Supabase não configurado.'));
    }
    final String? userId = client.auth.currentUser?.id;
    if (userId == null) {
      return const Left(ServerFailure('Usuário não autenticado.'));
    }
    try {
      final Map<String, dynamic> data = await client
          .from(_table)
          .insert(<String, dynamic>{
            'nome': nome.trim(),
            'telefone': telefone.trim(),
            'activation_code': activationCode.trim(),
            'owner_id': userId,
          })
          .select()
          .single();
      return Right(EmpresaModel.fromJson(data).toDomain());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
