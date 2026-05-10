import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import 'package:codebase/core/error/failures.dart';
import 'package:codebase/core/network/dio_client.dart';
import 'package:codebase/core/utils/app_logger.dart';
import 'package:codebase/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:codebase/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:codebase/features/auth/domain/entities/user.dart';
import 'package:codebase/features/auth/domain/repositories/auth_repository.dart';

/// Implémentation concrète du contrat [AuthRepository].
///
/// Rôle : orchestrer les datasources (remote + local) et convertir
/// les exceptions techniques en Failure du domaine.
///
/// Le domaine et la présentation ne voient JAMAIS DioException, etc.
final class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthRemoteDatasource remote,
    required AuthLocalDatasource local,
  }) : _remote = remote,
       _local = local;

  final AuthRemoteDatasource _remote;
  final AuthLocalDatasource _local;

  // StreamController pour diffuser l'état d'auth en temps réel
  static final _authStateController = StreamController<User?>.broadcast();

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remote.login({
        'email': email,
        'password': password,
      });

      // 1. Persister le token de façon sécurisée
      await _local.saveToken(response.token);

      // 2. Cacher le profil pour accès offline
      await _local.cacheUser(response.user);

      final user = response.user.toDomain();

      // 3. Notifier les listeners de l'état d'auth
      _authStateController.add(user);

      AppLogger.i('Login success: ${user.email}');
      return Right(user);
    } on DioException catch (e, st) {
      AppLogger.e('Login failed', e, st);
      return Left(dioExceptionToFailure(e));
    } catch (e, st) {
      AppLogger.e('Unexpected login error', e, st);
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      // Tenter un logout serveur (invalidation token)
      // Si ça échoue, on déconnecte quand même localement
      await _remote.logout().catchError((_) {
        AppLogger.w('Server logout failed, proceeding with local logout');
      });

      await _local.clearAll();
      _authStateController.add(null);

      AppLogger.i('Logout success');
      return const Right(unit);
    } catch (e, st) {
      AppLogger.e('Logout error', e, st);
      // Forcer le nettoyage local même en cas d'erreur
      await _local.clearAll().catchError((_) {});
      _authStateController.add(null);
      return const Left(CacheFailure('Erreur lors de la déconnexion.'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      // Stratégie : réseau en priorité, cache en fallback
      final remote = await _remote.getProfile();
      await _local.cacheUser(remote);
      return Right(remote.toDomain());
    } on DioException catch (e, st) {
      AppLogger.w('Remote getCurrentUser failed, trying cache', e, st);
      // Fallback cache
      final cached = await _local.getCachedUser();
      if (cached != null) return Right(cached.toDomain());
      return Left(dioExceptionToFailure(e));
    } catch (e, st) {
      AppLogger.e('getCurrentUser unexpected error', e, st);
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Stream<User?> watchAuthState() => _authStateController.stream;
}
