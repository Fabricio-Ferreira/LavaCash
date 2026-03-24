import '../../domain/entities/license.dart';

class LicenseModel {
  const LicenseModel({
    required this.id,
    required this.deviceId,
    required this.nomeLavagem,
    required this.isActive,
  });

  final String id;
  final String deviceId;
  final String nomeLavagem;
  final bool isActive;

  factory LicenseModel.fromJson(Map<String, dynamic> json) {
    return LicenseModel(
      id: json['id'] as String,
      deviceId: json['device_id'] as String,
      nomeLavagem: json['nome_lavagem'] as String,
      isActive: json['is_active'] as bool,
    );
  }

  License toDomain() {
    return License(
      id: id,
      deviceId: deviceId,
      nomeLavagem: nomeLavagem,
      isActive: isActive,
    );
  }
}
