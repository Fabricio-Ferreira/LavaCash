import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import 'package:lava_cash/core/domain/entities/service_catalog_item.dart';

abstract class ServiceCatalogRepository {
  Future<Either<Failure, List<ServiceCatalogItem>>> listActiveCatalog();

  Future<Either<Failure, List<ServiceCatalogItem>>> listMaisUtilizados();

  Future<Either<Failure, ServiceCatalogItem>> createItem({
    required String nome,
    required double valorPadrao,
    String? observacao,
    required bool isMaisUtilizado,
  });

  Future<Either<Failure, ServiceCatalogItem>> updateItem({
    required String id,
    required String nome,
    required double valorPadrao,
    String? observacao,
    required bool isMaisUtilizado,
  });

  Future<Either<Failure, Unit>> softDeleteItem(String id);
}
