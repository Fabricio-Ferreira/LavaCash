import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../../../data/models/client_model.dart';
import '../../../../data/models/service_record_model.dart';
import 'package:lava_cash/core/domain/entities/service_record.dart';
import 'package:lava_cash/core/domain/entities/vehicle.dart';
import 'package:lava_cash/core/domain/entities/vehicle_with_client.dart';
import 'package:lava_cash/core/domain/service/repositories/service_repository.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  ServiceRepositoryImpl({required SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;

  static const String _vehicleTenantMessage =
      'Veículo não encontrado ou sem permissão.';

  @override
  Future<Either<Failure, VehicleWithClient>> getVehicleWithClient(
    String vehicleId,
  ) async {
    if (_client == null) {
      return const Left(ServerFailure('Supabase not configured'));
    }
    try {
      final Map<String, dynamic> row =
          await _client
              .from('veiculos')
              .select('*, clientes(*)')
              .eq('id', vehicleId)
              .single();
      final dynamic rawClient = row['clientes'];
      final ClientModel clientModel = _parseClient(rawClient);
      final Vehicle vehicle = Vehicle(
        id: row['id'] as String,
        placa: row['placa'] as String,
        clienteId: row['cliente_id'] as String,
        client: clientModel.toDomain(),
      );
      return Right(
        VehicleWithClient(vehicle: vehicle, client: clientModel.toDomain()),
      );
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ServiceRecord>> getServiceById(
    String serviceId,
  ) async {
    if (_client == null) {
      return const Left(ServerFailure('Supabase not configured'));
    }
    try {
      final Map<String, dynamic> row =
          await _client
              .from('atendimentos')
              .select()
              .eq('id', serviceId)
              .single();
      return Right(ServiceRecordModel.fromJson(row).toDomain());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ServiceRecord>> startService(String vehicleId) async {
    if (_client == null) {
      return const Left(ServerFailure('Supabase not configured'));
    }

    try {
      final Map<String, dynamic>? veiculoRow =
          await _client
              .from('veiculos')
              .select('empresa_id')
              .eq('id', vehicleId)
              .maybeSingle();
      if (veiculoRow == null) {
        return const Left(ServerFailure(_vehicleTenantMessage));
      }
      final String? empresaId = veiculoRow['empresa_id']?.toString();
      if (empresaId == null || empresaId.isEmpty) {
        return const Left(ServerFailure(_vehicleTenantMessage));
      }
      final Map<String, dynamic> row =
          await _client
              .from('atendimentos')
              .insert(<String, dynamic>{
                'veiculo_id': vehicleId,
                'status': 'em_andamento',
                'empresa_id': empresaId,
              })
              .select()
              .single();
      return Right(ServiceRecordModel.fromJson(row).toDomain());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ServiceRecord>> updateServiceDetails({
    required String serviceId,
    required double valor,
    String? nomeServico,
    String? observacao,
  }) async {
    if (_client == null) {
      return const Left(ServerFailure('Supabase not configured'));
    }
    try {
      final Map<String, dynamic> row =
          await _client
              .from('atendimentos')
              .update(<String, dynamic>{
                'valor': valor,
                'nome_servico': nomeServico,
                'observacao': observacao,
                'updated_at': DateTime.now().toUtc().toIso8601String(),
              })
              .eq('id', serviceId)
              .select()
              .single();
      return Right(ServiceRecordModel.fromJson(row).toDomain());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> cancelService(String serviceId) async {
    if (_client == null) {
      return const Left(ServerFailure('Supabase not configured'));
    }
    try {
      await _client
          .from('atendimentos')
          .update(<String, dynamic>{
            'status': 'cancelado',
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', serviceId);
      return const Right(unit);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  ClientModel _parseClient(dynamic raw) {
    if (raw is List && raw.isNotEmpty) {
      return ClientModel.fromJson(raw.first as Map<String, dynamic>);
    }
    if (raw is Map<String, dynamic>) {
      return ClientModel.fromJson(raw);
    }
    throw const FormatException('Invalid clientes payload');
  }
}
