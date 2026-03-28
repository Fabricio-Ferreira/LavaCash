import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../../../domain/entities/vehicle_with_client.dart';
import '../adapters/vehicle_search_rpc_adapter.dart';
import '../../domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl({required SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;

  @override
  Future<Either<Failure, List<VehicleWithClient>>> search(String query) async {
    final SupabaseClient? supabase = _client;
    if (supabase == null) {
      return const Left(ServerFailure('Supabase not configured'));
    }
    final String trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const Right([]);
    }
    try {
      final dynamic response = await supabase.rpc(
        'search_vehicles_normalized',
        params: <String, dynamic>{'p_query': trimmed},
      );
      if (response == null) {
        return const Right(<VehicleWithClient>[]);
      }
      if (response is! List<dynamic>) {
        return const Left(ServerFailure('Invalid search response'));
      }
      final List<VehicleWithClient> results = <VehicleWithClient>[];
      for (final dynamic row in response) {
        if (row is! Map<String, dynamic>) {
          continue;
        }
        results.add(VehicleSearchRpcAdapter.toVehicleWithClient(row));
      }
      return Right(results);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
