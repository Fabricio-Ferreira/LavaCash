import 'package:equatable/equatable.dart';

class License extends Equatable {
  const License({
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
  @override
  List<Object?> get props => <Object?>[
    id,
    deviceId,
    establishmentName,
    phone,
    licenseType,
    isActive,
    createdAt,
    expiresAt,
    priceCents,
    isDeviceRegistered,
    activationCode,
  ];
}
