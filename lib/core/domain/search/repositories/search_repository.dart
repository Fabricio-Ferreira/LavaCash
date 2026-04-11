import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import 'package:lava_cash/core/domain/entities/vehicle_with_client.dart';

abstract class SearchRepository {
  Future<Either<Failure, List<VehicleWithClient>>> search(String query);
}
