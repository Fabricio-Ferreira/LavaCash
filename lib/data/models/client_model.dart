import '../../domain/entities/client.dart';

class ClientModel {
  const ClientModel({
    required this.id,
    required this.nome,
    required this.telefone,
  });

  final String id;
  final String nome;
  final String telefone;

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] as String,
      nome: json['nome'] as String,
      telefone: json['telefone'] as String,
    );
  }

  Client toDomain() {
    return Client(
      id: id,
      nome: nome,
      telefone: telefone,
    );
  }
}
