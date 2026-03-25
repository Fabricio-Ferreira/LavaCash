import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../domain/entities/service_record.dart';
import '../repositories/service_repository.dart';

class StartService {
  StartService({required ServiceRepository repository})
    : _repository = repository;

  final ServiceRepository _repository;

  Future<Either<Failure, ServiceRecord>> call(String vehicleId) {
    return _repository.startService(vehicleId);
  }
}
