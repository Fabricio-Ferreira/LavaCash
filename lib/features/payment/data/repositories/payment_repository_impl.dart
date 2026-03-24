import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../../../domain/entities/payment_method.dart';
import '../../domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl({required SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;

  @override
  Future<Either<Failure, Unit>> completePayment({
    required String serviceId,
    required double valor,
    required PaymentMethod formaPagamento,
  }) async {
    if (_client == null) {
      return const Left(ServerFailure('Supabase not configured'));
    }
    try {
      final Map<String, dynamic> row = await _client
          .from('atendimentos')
          .select('hora_entrada')
          .eq('id', serviceId)
          .single();
      final DateTime entrada =
          DateTime.parse(row['hora_entrada'] as String).toUtc();
      final DateTime saida = DateTime.now().toUtc();
      final int duracao = saida.difference(entrada).inMinutes;
      await _client.from('atendimentos').update(<String, dynamic>{
        'valor': valor,
        'forma_pagamento': formaPagamento.dbValue,
        'hora_saida': saida.toIso8601String(),
        'duracao_minutos': duracao,
        'status': 'finalizado',
        'updated_at': saida.toIso8601String(),
      }).eq('id', serviceId);
      return const Right(unit);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
