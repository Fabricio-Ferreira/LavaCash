import 'package:equatable/equatable.dart';

class Empresa extends Equatable {
  const Empresa({
    required this.id,
    required this.nome,
    this.telefone,
    required this.activationCode,
    this.ownerId,
  });

  final String id;
  final String nome;
  final String? telefone;
  final String activationCode;
  final String? ownerId;

  @override
  List<Object?> get props => <Object?>[id, nome, telefone, activationCode, ownerId];
}
