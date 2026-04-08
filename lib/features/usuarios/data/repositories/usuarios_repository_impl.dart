import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../domain/entities/empresa_usuario.dart';
import '../../domain/repositories/usuarios_repository.dart';
import '../models/empresa_usuario_model.dart';

class UsuariosRepositoryImpl implements UsuariosRepository {
  UsuariosRepositoryImpl({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;

  static const String _table = 'empresa_usuarios';
  static const String _convitesTable = 'empresa_convites';
  static const String _rpcListEnriched = 'list_empresa_usuarios_enriched';

  @override
  Future<Either<Failure, List<EmpresaUsuario>>> listUsuarios(
    String empresaId,
  ) async {
    final SupabaseClient? client = _client;
    if (client == null) return const Right(<EmpresaUsuario>[]);
    try {
      final List<dynamic> data = await client.rpc(
        _rpcListEnriched,
        params: <String, dynamic>{'p_empresa_id': empresaId},
      );
      final List<EmpresaUsuario> usuarios = data
          .map(
            (dynamic e) => EmpresaUsuarioModel.fromJson(
              Map<String, dynamic>.from(e as Map),
            ).toDomain(),
          )
          .toList();
      return Right(usuarios);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateRole({
    required String userId,
    required String empresaId,
    required UserRole role,
  }) async {
    final SupabaseClient? client = _client;
    if (client == null) {
      return const Left(ServerFailure('Supabase não configurado.'));
    }
    try {
      await client
          .from(_table)
          .update(<String, dynamic>{'role': role.name})
          .eq('user_id', userId)
          .eq('empresa_id', empresaId);
      return const Right(unit);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> removeUsuario({
    required String userId,
    required String empresaId,
  }) async {
    final SupabaseClient? client = _client;
    if (client == null) {
      return const Left(ServerFailure('Supabase não configurado.'));
    }
    try {
      await client
          .from(_table)
          .delete()
          .eq('user_id', userId)
          .eq('empresa_id', empresaId);
      return const Right(unit);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> addConvite({
    required String empresaId,
    required String activationCode,
    required UserRole role,
    String? membroNome,
  }) async {
    final SupabaseClient? client = _client;
    if (client == null) {
      return const Left(ServerFailure('Supabase não configurado.'));
    }
    try {
      final String trimmedCode = activationCode.trim();
      final Map<String, dynamic> row = <String, dynamic>{
        'empresa_id': empresaId,
        'activation_code': trimmedCode,
        'role': role.name,
        'membro_nome': role == UserRole.operador
            ? membroNome?.trim()
            : null,
      };
      await client.from(_convitesTable).upsert(row);
      return const Right(unit);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
