import 'package:equatable/equatable.dart';

class UserSession extends Equatable {
  const UserSession({
    required this.userId,
    required this.email,
  });

  final String userId;
  final String email;

  @override
  List<Object?> get props => <Object?>[userId, email];
}
