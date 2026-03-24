import 'package:equatable/equatable.dart';

class Client extends Equatable {
  const Client({
    required this.id,
    required this.nome,
    required this.telefone,
  });

  final String id;
  final String nome;
  final String telefone;

  @override
  List<Object?> get props => [id, nome, telefone];
}
