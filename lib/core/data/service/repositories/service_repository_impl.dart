import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../../../data/models/client_model.dart';
import '../../../../data/models/service_record_model.dart';
import 'package:lava_cash/core/domain/entities/attendance_service_line.dart';
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

  @override
  Future<Either<Failure, List<AttendanceServiceLine>>>
  listAttendanceServiceLines(String atendimentoId) async {
    if (_client == null) {
      return const Left(ServerFailure('Supabase not configured'));
    }
    try {
      final List<dynamic> rows = await _client
          .from('atendimento_servicos')
          .select()
          .eq('atendimento_id', atendimentoId)
          .order('sort_order', ascending: true);
      final List<AttendanceServiceLine> list = rows
          .map((dynamic e) => _lineFromRow(e as Map<String, dynamic>))
          .toList();
      return Right(list);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AttendanceServiceLine>> addAttendanceServiceLine({
    required String atendimentoId,
    String? servicoCatalogoId,
    required String nome,
    required double valor,
    String? observacao,
  }) async {
    if (_client == null) {
      return const Left(ServerFailure('Supabase not configured'));
    }
    try {
      final List<dynamic> existing = await _client
          .from('atendimento_servicos')
          .select('sort_order')
          .eq('atendimento_id', atendimentoId)
          .order('sort_order', ascending: false)
          .limit(1);
      int sortOrder = 0;
      if (existing.isNotEmpty) {
        final Map<String, dynamic> first =
            existing.first as Map<String, dynamic>;
        sortOrder = (first['sort_order'] as int? ?? 0) + 1;
      }
      final Map<String, dynamic> insertMap = <String, dynamic>{
        'atendimento_id': atendimentoId,
        'nome': nome,
        'valor': valor,
        'sort_order': sortOrder,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };
      if (servicoCatalogoId != null && servicoCatalogoId.isNotEmpty) {
        insertMap['servico_catalogo_id'] = servicoCatalogoId;
      }
      if (observacao != null && observacao.isNotEmpty) {
        insertMap['observacao'] = observacao;
      }
      final Map<String, dynamic> row = await _client
          .from('atendimento_servicos')
          .insert(insertMap)
          .select()
          .single();
      return Right(_lineFromRow(row));
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AttendanceServiceLine>> updateAttendanceServiceLine({
    required String lineId,
    required String nome,
    required double valor,
    String? observacao,
  }) async {
    if (_client == null) {
      return const Left(ServerFailure('Supabase not configured'));
    }
    try {
      final Map<String, dynamic> row = await _client
          .from('atendimento_servicos')
          .update(<String, dynamic>{
            'nome': nome,
            'valor': valor,
            'observacao':
                observacao != null && observacao.isEmpty ? null : observacao,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', lineId)
          .select()
          .single();
      return Right(_lineFromRow(row));
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAttendanceServiceLine(
    String lineId,
  ) async {
    if (_client == null) {
      return const Left(ServerFailure('Supabase not configured'));
    }
    try {
      await _client.from('atendimento_servicos').delete().eq('id', lineId);
      return const Right(unit);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  AttendanceServiceLine _lineFromRow(Map<String, dynamic> row) {
    return AttendanceServiceLine(
      id: row['id'] as String,
      atendimentoId: row['atendimento_id'] as String,
      servicoCatalogoId: row['servico_catalogo_id']?.toString(),
      nome: row['nome'] as String,
      valor: _lineValor(row['valor']),
      observacao: row['observacao'] as String?,
      sortOrder: row['sort_order'] as int? ?? 0,
    );
  }

  double _lineValor(Object? value) {
    if (value == null) {
      return 0;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString()) ?? 0;
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
