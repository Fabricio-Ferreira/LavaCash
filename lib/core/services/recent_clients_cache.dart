import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lava_cash/core/domain/entities/client.dart';
import 'package:lava_cash/core/domain/entities/vehicle.dart';
import 'package:lava_cash/core/domain/entities/vehicle_with_client.dart';

const String _prefsKeyRecentClients = 'recent_clients';

class RecentClientEntry {
  const RecentClientEntry({
    required this.vehicleId,
    required this.placa,
    required this.clienteNome,
    required this.clienteId,
    required this.telefone,
  });

  final String vehicleId;
  final String placa;
  final String clienteNome;
  final String clienteId;
  final String telefone;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'vehicleId': vehicleId,
      'placa': placa,
      'clienteNome': clienteNome,
      'clienteId': clienteId,
      'telefone': telefone,
    };
  }

  factory RecentClientEntry.fromJson(Map<String, dynamic> json) {
    return RecentClientEntry(
      vehicleId: json['vehicleId'] as String? ?? '',
      placa: json['placa'] as String? ?? '',
      clienteNome: json['clienteNome'] as String? ?? '',
      clienteId: json['clienteId'] as String? ?? '',
      telefone: json['telefone'] as String? ?? '',
    );
  }

  VehicleWithClient toVehicleWithClient() {
    final Client client = Client(
      id: clienteId.isEmpty ? vehicleId : clienteId,
      nome: clienteNome,
      telefone: telefone,
    );
    final Vehicle vehicle = Vehicle(
      id: vehicleId,
      placa: placa,
      clienteId: client.id,
      client: client,
    );
    return VehicleWithClient(vehicle: vehicle, client: client);
  }
}

class RecentClientsCache extends GetxController {
  final RxList<RecentClientEntry> entries = <RecentClientEntry>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? raw = prefs.getStringList(_prefsKeyRecentClients);
    if (raw == null || raw.isEmpty) {
      return;
    }
    final List<RecentClientEntry> loaded = <RecentClientEntry>[];
    for (final String line in raw) {
      try {
        final Map<String, dynamic> map =
            jsonDecode(line) as Map<String, dynamic>;
        loaded.add(RecentClientEntry.fromJson(map));
      } on Object {
        continue;
      }
    }
    entries.assignAll(loaded);
  }

  Future<void> _persist() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> lines =
        entries.map((RecentClientEntry e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_prefsKeyRecentClients, lines);
  }

  void save(VehicleWithClient item) {
    final RecentClientEntry entry = RecentClientEntry(
      vehicleId: item.vehicle.id,
      placa: item.vehicle.placa,
      clienteNome: item.client.nome,
      clienteId: item.client.id,
      telefone: item.client.telefone,
    );
    entries.removeWhere(
      (RecentClientEntry e) => e.vehicleId == entry.vehicleId,
    );
    entries.insert(0, entry);
    while (entries.length > 3) {
      entries.removeLast();
    }
    _persist();
  }

  VehicleWithClient? vehicleForId(String vehicleId) {
    for (final RecentClientEntry e in entries) {
      if (e.vehicleId == vehicleId) {
        return e.toVehicleWithClient();
      }
    }
    return null;
  }
}
