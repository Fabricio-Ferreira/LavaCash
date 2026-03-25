import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/client_model.dart';
import '../../../../domain/entities/vehicle.dart';
import '../../domain/repositories/registration_repository.dart';

class RegistrationRepositoryImpl implements RegistrationRepository {
  RegistrationRepositoryImpl({required SupabaseClient? client})
    : _client = client;

  final SupabaseClient? _client;

  @override
  Future<Either<Failure, Vehicle>> registerClientAndVehicle({
    required String nome,
    required String telefone,
    required String placa,
  }) async {
    if (_client == null) {
      return const Left(ServerFailure('Supabase not configured'));
    }
    final String normalizedPlate = AppFormatters.formatPlate(placa);
    try {
      final Map<String, dynamic> clientInsert =
          await _client
              .from('clientes')
              .insert(<String, dynamic>{
                'nome': nome.trim(),
                'telefone': telefone.trim(),
              })
              .select()
              .single();
      final ClientModel clientModel = ClientModel.fromJson(clientInsert);
      final Map<String, dynamic> vehicleInsert =
          await _client
              .from('veiculos')
              .insert(<String, dynamic>{
                'placa': normalizedPlate,
                'cliente_id': clientModel.id,
              })
              .select('*, clientes(*)')
              .single();
      return Right(
        Vehicle(
          id: vehicleInsert['id'] as String,
          placa: vehicleInsert['placa'] as String,
          clienteId: vehicleInsert['cliente_id'] as String,
          client: clientModel.toDomain(),
        ),
      );
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
