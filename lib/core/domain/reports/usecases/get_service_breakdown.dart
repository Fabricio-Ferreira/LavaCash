import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import 'package:lava_cash/core/domain/entities/service_breakdown_row.dart';
import '../repositories/report_repository.dart';

class GetServiceBreakdown {
  GetServiceBreakdown({required ReportRepository repository})
    : _repository = repository;

  final ReportRepository _repository;

  Future<Either<Failure, List<ServiceBreakdownRow>>> call(
    DateTime startInclusive,
    DateTime endInclusive,
  ) {
    return _repository.getServiceBreakdown(startInclusive, endInclusive);
  }
}
