import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/user_session.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;

  @override
  Future<Either<Failure, UserSession>> signIn({
    required String email,
    required String password,
  }) async {
    final SupabaseClient? client = _client;
    if (client == null) {
      return const Left(ServerFailure('Supabase não configurado.'));
    }
    try {
      final AuthResponse response = await client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final User? user = response.user;
      if (user == null) {
        return const Left(ServerFailure('Login falhou. Tente novamente.'));
      }
      return Right(UserSession(userId: user.id, email: user.email ?? email));
    } on AuthException catch (e) {
      return Left(ServerFailure(_mapAuthError(e.message)));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserSession>> signInOrSignUpWithActivationCode(
    String activationCode,
  ) async {
    final String trimmed = activationCode.trim();
    if (trimmed.isEmpty) {
      return const Left(ServerFailure('Código de ativação ausente.'));
    }
    final String email = _activationEmailFromCode(trimmed);
    final Either<Failure, UserSession> signInResult = await signIn(
      email: email,
      password: trimmed,
    );
    return signInResult.fold(
      (Failure failure) async {
        final String lower = failure.message.toLowerCase();
        if (lower.contains('incorretos') ||
            lower.contains('invalid login credentials')) {
          return signUp(email: email, password: trimmed);
        }
        return Left(failure);
      },
      Right.new,
    );
  }

  String _activationEmailFromCode(String activationCode) =>
      '$activationCode@lavacash.app';

  @override
  Future<Either<Failure, UserSession>> signUp({
    required String email,
    required String password,
  }) async {
    final SupabaseClient? client = _client;
    if (client == null) {
      return const Left(ServerFailure('Supabase não configurado.'));
    }
    try {
      final AuthResponse response = await client.auth.signUp(
        email: email.trim(),
        password: password,
      );
      final User? user = response.user;
      if (user == null) {
        return const Left(ServerFailure('Cadastro falhou. Tente novamente.'));
      }
      return Right(UserSession(userId: user.id, email: user.email ?? email));
    } on AuthException catch (e) {
      return Left(ServerFailure(_mapAuthError(e.message)));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  String _mapAuthError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Email ou senha incorretos.';
    }
    if (message.contains('Email not confirmed')) {
      return 'Confirme seu email antes de entrar.';
    }
    if (message.contains('User already registered')) {
      return 'Este email já está cadastrado.';
    }
    return message;
  }
}
