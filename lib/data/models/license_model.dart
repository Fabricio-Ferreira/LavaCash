import '../../domain/entities/license.dart';

class LicenseModel {
  const LicenseModel({
    required this.id,
    this.deviceId,
    required this.establishmentName,
    required this.phone,
    required this.licenseType,
    required this.isActive,
    this.createdAt,
    this.expiresAt,
    required this.priceCents,
    required this.isDeviceRegistered,
    this.activationCode,
  });

  final String id;
  final String? deviceId;
  final String establishmentName;
  final String phone;
  final String licenseType;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? expiresAt;
  final int priceCents;
  final bool isDeviceRegistered;
  final String? activationCode;

  factory LicenseModel.fromJson(Map<String, dynamic> json) {
    return LicenseModel(
      id: json['id'] as String,
      deviceId: json['device_id'] as String?,
      establishmentName: json['establishment_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      licenseType: json['license_type'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? false,
      createdAt: _parseDateTime(json['created_at']),
      expiresAt: _parseDateTime(json['expires_at']),
      priceCents: _parseInt(json['price_cents']),
      isDeviceRegistered: json['is_device_registered'] as bool? ?? false,
      activationCode: json['activation_code'] as String?,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static int _parseInt(dynamic value) {
    if (value == null) {
      return 0;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return 0;
  }

  License toDomain() {
    return License(
      id: id,
      deviceId: deviceId,
      establishmentName: establishmentName,
      phone: phone,
      licenseType: licenseType,
      isActive: isActive,
      createdAt: createdAt,
      expiresAt: expiresAt,
      priceCents: priceCents,
      isDeviceRegistered: isDeviceRegistered,
      activationCode: activationCode,
    );
  }
}
