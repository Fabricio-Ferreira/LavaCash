import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_session.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserSession>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserSession>> signUp({
    required String email,
    required String password,
  });

  /// Signs in with derived email/password from [activationCode], or signs up
  /// if the user does not exist yet (first device / first open).
  Future<Either<Failure, UserSession>> signInOrSignUpWithActivationCode(
    String activationCode,
  );
}
