import 'package:dartz/dartz.dart';

import 'package:codebase/core/error/failures.dart';

/// Contrat de base pour tous les UseCases.
///
/// Chaque UseCase encapsule un seul cas d'utilisation métier.
/// [T]      = type de retour en cas de succès
/// [Params] = paramètres d'entrée typés
///
/// Usage :
/// ```dart
/// final class LoginUseCase extends UseCase<User, LoginParams> {
///   @override
///   Future<Either<Failure, User>> call(LoginParams params) { ... }
/// }
/// ```
abstract class UseCase<T, Params> {
  const UseCase();

  Future<Either<Failure, T>> call(Params params);
}

/// Marqueur pour les UseCases sans paramètre.
///
/// Usage :
/// ```dart
/// final class GetCurrentUserUseCase extends UseCase<User, NoParams> {
///   @override
///   Future<Either<Failure, User>> call(NoParams _) { ... }
/// }
/// ```
final class NoParams {
  const NoParams();
}
