import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/expense.dart';

abstract class ExpenseRepository {
  Future<Either<Failure, List<Expense>>> listInDateRange({
    required DateTime startInclusive,
    required DateTime endInclusive,
  });

  Future<Either<Failure, Expense>> create({
    required String descricao,
    required String categoria,
    required double valor,
    required DateTime dataReferencia,
  });

  Future<Either<Failure, Expense>> update({
    required String id,
    required String descricao,
    required String categoria,
    required double valor,
  });

  Future<Either<Failure, Unit>> delete(String id);
}
