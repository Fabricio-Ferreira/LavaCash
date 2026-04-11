import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/expense_repository.dart';

class DeleteExpense {
  DeleteExpense({required ExpenseRepository repository})
    : _repository = repository;

  final ExpenseRepository _repository;

  Future<Either<Failure, Unit>> call(String id) {
    return _repository.delete(id);
  }
}
