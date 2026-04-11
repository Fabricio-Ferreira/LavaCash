import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class CreateExpense {
  CreateExpense({required ExpenseRepository repository})
    : _repository = repository;

  final ExpenseRepository _repository;

  Future<Either<Failure, Expense>> call({
    required String descricao,
    required String categoria,
    required double valor,
    required DateTime dataReferencia,
  }) {
    return _repository.create(
      descricao: descricao,
      categoria: categoria,
      valor: valor,
      dataReferencia: dataReferencia,
    );
  }
}
