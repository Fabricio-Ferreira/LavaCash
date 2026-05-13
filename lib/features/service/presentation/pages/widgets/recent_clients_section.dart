import 'package:flutter/material.dart';

import '../../../../../core/domain/entities/vehicle_with_client.dart';
import '../../../../../core/services/recent_clients_cache.dart';
import '../../../../../core/utils/formatters.dart';
import 'client_result_card.dart';

class RecentClientsSection extends StatefulWidget {
  const RecentClientsSection({
    super.key,
    required this.entries,
    required this.selectedVehicleId,
    required this.onSelectVehicle,
    this.onEditCliente,
  });

  final List<RecentClientEntry> entries;
  final String? selectedVehicleId;
  final ValueChanged<String> onSelectVehicle;
  final void Function(VehicleWithClient)? onEditCliente;

  @override
  State<RecentClientsSection> createState() => _RecentClientsSectionState();
}

class _RecentClientsSectionState extends State<RecentClientsSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimations = List<Animation<double>>.generate(3, (int i) {
      final List<double> starts = <double>[0.0, 0.15, 0.30];
      final List<double> ends = <double>[0.6, 0.75, 0.90];
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(starts[i], ends[i], curve: Curves.easeOutCubic),
        ),
      );
    });
    _slideAnimations = List<Animation<Offset>>.generate(3, (int i) {
      final List<double> starts = <double>[0.0, 0.15, 0.30];
      final List<double> ends = <double>[0.6, 0.75, 0.90];
      return Tween<Offset>(
        begin: const Offset(0, 0.1),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(starts[i], ends[i], curve: Curves.easeOutCubic),
        ),
      );
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int n = widget.entries.length.clamp(0, 3);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List<Widget>.generate(n, (int index) {
        final RecentClientEntry e = widget.entries[index];
        final bool isSelected = widget.selectedVehicleId == e.vehicleId;
        return Padding(
          padding: EdgeInsets.only(bottom: index < n - 1 ? 16 : 0),
          child: FadeTransition(
            opacity: _fadeAnimations[index],
            child: SlideTransition(
              position: _slideAnimations[index],
              child: ClientResultCard(
                clientName: e.clienteNome,
                plateFormatted: AppFormatters.formatPlate(e.placa),
                isSelected: isSelected,
                onTap: () => widget.onSelectVehicle(e.vehicleId),
                onEditPressed:
                    widget.onEditCliente != null
                        ? () => widget.onEditCliente!(e.toVehicleWithClient())
                        : null,
              ),
            ),
          ),
        );
      }),
    );
  }
}
