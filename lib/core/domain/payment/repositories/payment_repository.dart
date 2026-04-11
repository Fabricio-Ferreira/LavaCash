import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import 'package:lava_cash/core/domain/entities/payment_method.dart';

abstract class PaymentRepository {
  Future<Either<Failure, Unit>> completePayment({
    required String serviceId,
    required double valor,
    required PaymentMethod formaPagamento,
  });
}
