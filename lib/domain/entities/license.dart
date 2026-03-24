import 'package:equatable/equatable.dart';

class License extends Equatable {
  const License({
    required this.id,
    required this.deviceId,
    required this.nomeLavagem,
    required this.isActive,
  });

  final String id;
  final String deviceId;
  final String nomeLavagem;
  final bool isActive;

  @override
  List<Object?> get props => [id, deviceId, nomeLavagem, isActive];
}
