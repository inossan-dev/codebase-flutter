import 'package:equatable/equatable.dart';

/// Hiérarchie d'erreurs domaine.
///
/// Utilisation avec dartz Either<Failure, T> :
///   Future<Either<Failure, User>> login(...)
///
/// Avantages vs throw/catch :
/// - Le type de retour documente explicitement les cas d'erreur
/// - Le compilateur force le traitement de chaque cas
/// - Pas d'exception silencieuse qui passe à travers les layers
sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Erreur réseau (timeout, pas de connexion, erreur HTTP 5xx)
final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Erreur réseau. Vérifiez votre connexion.']);
}

/// Ressource non trouvée (HTTP 404)
final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Ressource introuvable.']);
}

/// Authentification invalide (HTTP 401)
final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Session expirée. Reconnectez-vous.']);
}

/// Accès refusé (HTTP 403)
final class ForbiddenFailure extends Failure {
  const ForbiddenFailure([super.message = 'Accès refusé.']);
}

/// Erreur de validation ou de parsing
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Erreur interne serveur (HTTP 5xx)
final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Erreur serveur. Réessayez plus tard.']);
}

/// Erreur de cache / stockage local
final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Erreur de stockage local.']);
}

/// Cas inattendu, à logger impérativement
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Une erreur inattendue est survenue.']);
}
