import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lava_cash/core/domain/entities/service_catalog_item.dart';
import 'package:lava_cash/features/service/presentation/pages/widgets/service_detail_form.dart';
import 'package:lava_cash/features/service_catalog/presentation/controllers/service_catalog_controller.dart';

Future<void> showServiceCatalogEditorSheet({
  required BuildContext context,
  ServiceCatalogItem? existing,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext ctx) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: ServiceCatalogEditorFormBody(
          existing: existing,
          onPersist: ({
            required String nome,
            required double valorPadrao,
            String? observacao,
            required bool isMaisUtilizado,
          }) {
            final ServiceCatalogController cat =
                Get.find<ServiceCatalogController>();
            if (existing == null) {
              return cat.createItem(
                nome: nome,
                valorPadrao: valorPadrao,
                observacao: observacao,
                isMaisUtilizado: isMaisUtilizado,
              );
            }
            return cat.updateItem(
              id: existing.id,
              nome: nome,
              valorPadrao: valorPadrao,
              observacao: observacao,
              isMaisUtilizado: isMaisUtilizado,
            );
          },
          afterPersistSuccess: () async {
            await Get.find<ServiceCatalogController>().refreshCatalog();
          },
        ),
      );
    },
  );
}
