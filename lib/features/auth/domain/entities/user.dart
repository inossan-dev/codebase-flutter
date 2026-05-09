import 'package:equatable/equatable.dart';

/// Entité domaine User.
///
/// Règles :
/// - Immutable (tous les champs final)
/// - Pas de dépendance data/infra (pas de json, pas de framework)
/// - Equatable pour la comparaison par valeur (utile dans les tests et Riverpod)
final class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;

  @override
  List<Object?> get props => [id, email, displayName, avatarUrl];
}
