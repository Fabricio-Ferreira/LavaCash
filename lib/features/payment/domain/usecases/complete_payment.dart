import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../domain/entities/payment_method.dart';
import '../repositories/payment_repository.dart';

class CompletePayment {
  CompletePayment({required PaymentRepository repository})
      : _repository = repository;

  final PaymentRepository _repository;

  Future<Either<Failure, Unit>> call({
    required String serviceId,
    required double valor,
    required PaymentMethod formaPagamento,
  }) {
    return _repository.completePayment(
      serviceId: serviceId,
      valor: valor,
      formaPagamento: formaPagamento,
    );
  }
}
