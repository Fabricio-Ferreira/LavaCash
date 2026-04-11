import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class ListExpensesInRange {
  ListExpensesInRange({required ExpenseRepository repository})
    : _repository = repository;

  final ExpenseRepository _repository;

  Future<Either<Failure, List<Expense>>> call({
    required DateTime startInclusive,
    required DateTime endInclusive,
  }) {
    return _repository.listInDateRange(
      startInclusive: startInclusive,
      endInclusive: endInclusive,
    );
  }
}
