import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../domain/entities/empresa.dart';
import '../../domain/repositories/empresa_repository.dart';
import '../models/empresa_model.dart';

class EmpresaRepositoryImpl implements EmpresaRepository {
  EmpresaRepositoryImpl({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;

  static const String _table = 'empresas';
  static const String _claimRpc = 'claim_empresa';
  static const String _acceptConviteRpc = 'accept_empresa_convite';
  static const String _registerUserRpc = 'register_user_in_empresa';
  static const String _myRoleRpc = 'get_my_role';
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
      if (result == null) return const Right(null);
      return fetchOwn();
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Empresa?>> acceptConvite(
    String activationCode,
  ) async {
    final SupabaseClient? client = _client;
    if (client == null || activationCode.isEmpty) return const Right(null);
    try {
      final dynamic empresaId = await client.rpc(
        _acceptConviteRpc,
        params: <String, dynamic>{'p_activation_code': activationCode},
      );
      if (empresaId == null) return const Right(null);
      final List<dynamic> data = await client
          .from(_table)
          .select()
          .eq('id', empresaId as String)
          .limit(1);
      if (data.isEmpty) return const Right(null);
      return Right(
        EmpresaModel.fromJson(Map<String, dynamic>.from(data.first as Map))
            .toDomain(),
      );
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserRole?>> fetchMyRole() async {
    final SupabaseClient? client = _client;
    if (client == null) return const Right(null);
    try {
      final dynamic result = await client.rpc(_myRoleRpc);
      if (result == null) return const Right(null);
      return Right(UserRole.fromString(result as String));
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> registerUserInEmpresa({
    required String empresaId,
    required UserRole role,
  }) async {
    final SupabaseClient? client = _client;
    if (client == null) {
      return const Left(ServerFailure('Supabase não configurado.'));
    }
    try {
      await client.rpc(
        _registerUserRpc,
        params: <String, dynamic>{
          'p_empresa_id': empresaId,
          'p_role': role.name,
        },
      );
      return const Right(unit);
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
