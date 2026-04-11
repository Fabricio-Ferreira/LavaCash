import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/client_model.dart';
import 'package:lava_cash/core/domain/entities/vehicle.dart';
import 'package:lava_cash/core/domain/registration/repositories/registration_repository.dart';

class RegistrationRepositoryImpl implements RegistrationRepository {
  RegistrationRepositoryImpl({required SupabaseClient? client})
    : _client = client;

  final SupabaseClient? _client;

  static const String _sessionRequiredMessage =
      'Sessão expirada. Entre novamente.';

  static const String _empresaRequiredMessage =
      'Nenhuma empresa vinculada a esta conta. Reinicie o aplicativo.';

  @override
  Future<Either<Failure, Vehicle>> registerClientAndVehicle({
    required String nome,
    required String telefone,
    required String placa,
  }) async {
    if (_client == null) {
      return const Left(ServerFailure('Supabase not configured'));
    }
    final Session? session = _client.auth.currentSession;
    if (session == null) {
      return const Left(ServerFailure(_sessionRequiredMessage));
    }
    final String normalizedPlate = AppFormatters.formatPlate(placa);
    try {
      final Map<String, dynamic>? empresaRow =
          await _client
              .from('empresas')
              .select('id')
              .limit(1)
              .maybeSingle();
      if (empresaRow == null) {
        return const Left(ServerFailure(_empresaRequiredMessage));
      }
      final String empresaId = empresaRow['id']! as String;
      final Map<String, dynamic> clientInsert =
          await _client
              .from('clientes')
              .insert(<String, dynamic>{
                'nome': nome.trim(),
                'telefone': telefone.trim(),
                'empresa_id': empresaId,
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
                'empresa_id': empresaId,
              })
              .select()
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
