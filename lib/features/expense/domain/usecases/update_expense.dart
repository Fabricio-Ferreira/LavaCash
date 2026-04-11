import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class UpdateExpense {
  UpdateExpense({required ExpenseRepository repository})
    : _repository = repository;

  final ExpenseRepository _repository;

  Future<Either<Failure, Expense>> call({
    required String id,
    required String descricao,
    required String categoria,
    required double valor,
  }) {
    return _repository.update(
      id: id,
      descricao: descricao,
      categoria: categoria,
      valor: valor,
    );
  }
}
