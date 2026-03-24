import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../../../data/models/client_model.dart';
import '../../../../domain/entities/vehicle.dart';
import '../../../../domain/entities/vehicle_with_client.dart';
import '../../domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl({required SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;

  @override
  Future<Either<Failure, List<VehicleWithClient>>> search(String query) async {
    if (_client == null) {
      return const Left(ServerFailure('Supabase not configured'));
    }
    final String trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const Right([]);
    }
    try {
      final String pattern = '%$trimmed%';
      final List<dynamic> byPlate = await _client
          .from('veiculos')
          .select('*, clientes(*)')
          .ilike('placa', pattern);
      final List<dynamic> clientRows = await _client
          .from('clientes')
          .select('id')
          .ilike('nome', pattern);
      final List<String> clientIds = clientRows
          .map((dynamic e) => (e as Map<String, dynamic>)['id'] as String)
          .toList();
      List<dynamic> byClient = <dynamic>[];
      if (clientIds.isNotEmpty) {
        final String orFilter = clientIds
            .map((String id) => 'cliente_id.eq.$id')
            .join(',');
        byClient = await _client
            .from('veiculos')
            .select('*, clientes(*)')
            .or(orFilter);
      }
      final Map<String, Map<String, dynamic>> merged =
          <String, Map<String, dynamic>>{};
      for (final dynamic row in byPlate) {
        final Map<String, dynamic> map = row as Map<String, dynamic>;
        merged[map['id'] as String] = map;
      }
      for (final dynamic row in byClient) {
        final Map<String, dynamic> map = row as Map<String, dynamic>;
        merged[map['id'] as String] = map;
      }
      final List<VehicleWithClient> results = merged.values
          .map((Map<String, dynamic> json) => _mapVehicleWithClient(json))
          .toList();
      return Right(results);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  VehicleWithClient _mapVehicleWithClient(Map<String, dynamic> json) {
    final dynamic rawClient = json['clientes'];
    final ClientModel clientModel = _parseClient(rawClient);
    final Vehicle vehicle = Vehicle(
      id: json['id'] as String,
      placa: json['placa'] as String,
      clienteId: json['cliente_id'] as String,
      client: clientModel.toDomain(),
    );
    return VehicleWithClient(
      vehicle: vehicle,
      client: clientModel.toDomain(),
    );
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
