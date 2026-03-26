import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lava_cash/core/utils/app_snackbar.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/recent_clients_cache.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/entities/vehicle_with_client.dart';
import '../../../search/presentation/controllers/search_controller.dart';
import 'widgets/client_result_card.dart';
import 'widgets/novo_atendimento_app_bar.dart';
import 'widgets/novo_atendimento_bottom_cta.dart';
import 'widgets/novo_atendimento_empty_state.dart';
import 'widgets/novo_atendimento_register_button.dart';
import 'widgets/novo_atendimento_results_header.dart';
import 'widgets/novo_atendimento_search_field.dart';
import 'widgets/recent_clients_section.dart';

class NovoAtendimentoPage extends StatefulWidget {
  const NovoAtendimentoPage({super.key});

  @override
  State<NovoAtendimentoPage> createState() => _NovoAtendimentoPageState();
}

class _NovoAtendimentoPageState extends State<NovoAtendimentoPage> {
  String? _selectedVehicleId;

  VehicleSearchController get _search => Get.find<VehicleSearchController>();

  RecentClientsCache get _recentCache => Get.find<RecentClientsCache>();

  void _onSelectVehicle(String vehicleId) {
    setState(() {
      _selectedVehicleId = _selectedVehicleId == vehicleId ? null : vehicleId;
    });
  }

  void _navigateToRegistration() {
    Get.toNamed<void>(AppRoutes.registration);
  }

  void _startService() {
    final String? id = _selectedVehicleId;
    if (id == null || id.isEmpty) {
      return;
    }
    VehicleWithClient? vehicle;
    for (final VehicleWithClient v in _search.results) {
      if (v.vehicle.id == id) {
        vehicle = v;
        break;
      }
    }
    vehicle ??= _recentCache.vehicleForId(id);
    if (vehicle != null) {
      _recentCache.save(vehicle);
    }

    AppSnackbar.showSuccess('Atendimento iniciado com sucesso.');
    Get.toNamed<void>('${AppRoutes.service}/$id');
  }

  void _handleQueryChanged(String value) {
    _search.onQueryChanged(value);
    if (value.trim().isEmpty) {
      setState(() {
        _selectedVehicleId = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              NovoAtendimentoAppBar(onBack: Get.back<void>),
              Expanded(
                child: Obx(() {
                  final String q = _search.query.value.trim();
                  final bool hasQuery = q.isNotEmpty;
                  final bool isLoading = _search.isLoading.value;
                  final String err = _search.errorMessage.value;
                  final List<VehicleWithClient> items =
                      _search.results.toList();
                  final List<RecentClientEntry> recentEntries =
                      _recentCache.entries.toList();
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        NovoAtendimentoSearchField(
                          onChanged: _handleQueryChanged,
                        ),
                        const SizedBox(height: 24),
                        NovoAtendimentoResultsHeader(
                          title: hasQuery ? 'Resultados' : 'Clientes recentes',
                          monthLabel:
                              NovoAtendimentoResultsHeader.currentMonthLabel(),
                        ),
                        if (err.isNotEmpty) ...<Widget>[
                          SelectableText.rich(
                            TextSpan(
                              text: err,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 48),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (!hasQuery)
                          recentEntries.isEmpty
                              ? Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 32,
                                ),
                                child: Text(
                                  'Nenhum atendimento recente. Busque pelo '
                                  'nome ou placa.',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                              : RecentClientsSection(
                                key: ValueKey<String>(
                                  recentEntries
                                      .map((RecentClientEntry e) => e.vehicleId)
                                      .join('|'),
                                ),
                                entries: recentEntries,
                                selectedVehicleId: _selectedVehicleId,
                                onSelectVehicle: _onSelectVehicle,
                              )
                        else if (items.isEmpty)
                          NovoAtendimentoEmptyState(
                            onRegisterTap: _navigateToRegistration,
                          )
                        else
                          ...List<Widget>.generate(items.length, (int index) {
                            final VehicleWithClient item = items[index];
                            final String id = item.vehicle.id;
                            final bool isSelected = _selectedVehicleId == id;
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index < items.length - 1 ? 16 : 0,
                              ),
                              child: ClientResultCard(
                                key: ValueKey<String>(id),
                                clientName: item.client.nome,
                                plateFormatted: AppFormatters.formatPlate(
                                  item.vehicle.placa,
                                ),
                                isSelected: isSelected,
                                onTap: () => _onSelectVehicle(id),
                              ),
                            );
                          }),
                        const SizedBox(height: 24),
                        NovoAtendimentoRegisterButton(
                          onPressed: _navigateToRegistration,
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: NovoAtendimentoBottomCta(
        isEnabled: _selectedVehicleId != null,
        onPressed: _startService,
      ),
    );
  }
}
