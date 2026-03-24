import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../domain/entities/vehicle_with_client.dart';
import '../repositories/search_repository.dart';

class SearchVehicle {
  SearchVehicle({required SearchRepository repository})
      : _repository = repository;

  final SearchRepository _repository;

  Future<Either<Failure, List<VehicleWithClient>>> call(String query) {
    return _repository.search(query);
  }
}
