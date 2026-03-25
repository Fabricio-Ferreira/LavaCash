import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/constants.dart';
import '../../../../domain/entities/vehicle_with_client.dart';
import '../../domain/usecases/search_vehicle.dart';

class VehicleSearchController extends GetxController {
  VehicleSearchController({required SearchVehicle searchVehicle})
    : _searchVehicle = searchVehicle;

  final SearchVehicle _searchVehicle;

  final RxString query = ''.obs;
  final RxList<VehicleWithClient> results = <VehicleWithClient>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Timer? _debounce;

  void onQueryChanged(String value) {
    query.value = value;
    _debounce?.cancel();
    _debounce = Timer(AppConstants.searchDebounce, _runSearch);
  }

  Future<void> refreshSearch() => _runSearch();

  Future<void> _runSearch() async {
    final String trimmed = query.value.trim();
    if (trimmed.isEmpty) {
      results.clear();
      errorMessage.value = '';
      return;
    }
    isLoading.value = true;
    final Either<Failure, List<VehicleWithClient>> result =
        await _searchVehicle(trimmed);
    result.fold(
      (Failure failure) {
        errorMessage.value = failure.message;
        results.clear();
      },
      (List<VehicleWithClient> list) {
        errorMessage.value = '';
        results.assignAll(list);
      },
    );
    isLoading.value = false;
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}
