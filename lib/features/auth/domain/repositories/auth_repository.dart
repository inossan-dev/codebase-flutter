import 'package:dartz/dartz.dart';

import 'package:codebase/core/error/failures.dart';
import 'package:codebase/features/auth/domain/entities/user.dart';

/// Contrat du repository Auth (domaine).
///
/// Le domaine ne sait pas si les données viennent d'une API REST,
/// d'une BDD locale ou d'un mock. C'est l'inversion de dépendance.
///
/// Retourne Either<Failure, T> :
/// - Left(Failure) → erreur typée, traitée explicitement
/// - Right(T)      → succès
abstract interface class AuthRepository {
  /// Authentifie l'utilisateur et persiste le token.
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// Déconnecte et supprime le token local.
  Future<Either<Failure, Unit>> logout();

  /// Tente de récupérer l'utilisateur courant depuis le cache.
  Future<Either<Failure, User>> getCurrentUser();

  /// Émet l'état d'auth en temps réel.
  Stream<User?> watchAuthState();
}
