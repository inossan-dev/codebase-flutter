import 'package:dartz/dartz.dart';

import 'package:codebase/core/error/failures.dart';

/// Extensions sur Either<Failure, T> pour un pattern matching plus lisible.
///
/// Remplace le `.fold()` verbeux par des getters et méthodes expressives :
/// ```dart
/// final result = await loginUseCase(params);
/// if (result.isRight) {
///   final user = result.right;
/// }
/// ```
extension EitherX<L, R> on Either<L, R> {
  /// Retourne true si Right (succès).
  bool get isRight => fold((_) => false, (_) => true);

  /// Retourne true si Left (erreur).
  bool get isLeft => !isRight;

  /// Extrait la valeur droite. Throw si Left.
  /// À utiliser uniquement quand on a vérifié [isRight] avant.
  R get right => fold(
    (l) => throw StateError('Cannot get right value from Left: $l'),
    (r) => r,
  );

  /// Extrait la valeur gauche. Throw si Right.
  L get left => fold(
    (l) => l,
    (r) => throw StateError('Cannot get left value from Right: $r'),
  );
}

/// Extensions spécialisées pour Either<Failure, T>.
extension FailureEitherX<T> on Either<Failure, T> {
  /// Extrait le message d'erreur si Left, sinon null.
  String? get failureMessage => fold((failure) => failure.message, (_) => null);
}
