import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/app_global_controller.dart';
import '../../../../core/widgets/themed_refresh_indicator.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/utils/formatters.dart';
import '../controllers/search_controller.dart';

class SearchTabBody extends GetView<VehicleSearchController> {
  const SearchTabBody({super.key});

  @override
  Widget build(BuildContext context) {
    final AppGlobalController global = Get.find<AppGlobalController>();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(
            () => Text(
              global.nomeLavagem.value.isEmpty
                  ? 'Operação'
                  : global.nomeLavagem.value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Placa ou nome do cliente',
              prefixIcon: Icon(Icons.search),
            ),
            textCapitalization: TextCapitalization.characters,
            onChanged: controller.onQueryChanged,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Get.toNamed<void>(AppRoutes.registration);
                  },
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Novo cadastro'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ThemedRefreshIndicator(
              onRefresh: () => controller.refreshSearch(),
              child: Obx(
                () {
                  if (controller.isLoading.value) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(
                          height: 200,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ],
                    );
                  }
                  if (controller.errorMessage.value.isNotEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SelectableText.rich(
                          TextSpan(
                            text: controller.errorMessage.value,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  }
                  if (controller.results.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: Text(
                            controller.query.value.trim().isEmpty
                                ? 'Digite para buscar.'
                                : 'Nenhum veículo encontrado.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    );
                  }
                  return ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: controller.results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (BuildContext context, int index) {
                      final item = controller.results[index];
                      return Card(
                        child: ListTile(
                          title: Text(item.client.nome),
                          subtitle: Text(
                            '${AppFormatters.formatPlate(item.vehicle.placa)} · '
                            '${item.client.telefone}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Get.toNamed<void>(
                              '${AppRoutes.service}/${item.vehicle.id}',
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
