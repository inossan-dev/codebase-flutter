import 'package:codebase/features/auth/domain/entities/user.dart';

/// Modèle data : sérialisation JSON ↔ Dart.
///
/// Responsabilités :
/// - Mapper le JSON brut de l'API vers un objet typé
/// - Convertir vers l'entité domaine via [toDomain()]
/// - Ne contient PAS de logique métier
final class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String,
    email: json['email'] as String,
    displayName: json['display_name'] as String?,
    avatarUrl: json['avatar_url'] as String?,
  );

  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'display_name': displayName,
    'avatar_url': avatarUrl,
  };

  /// Conversion data → domaine.
  /// Le domaine ne connaît jamais UserModel, uniquement User.
  User toDomain() => User(
    id: id,
    email: email,
    displayName: displayName,
    avatarUrl: avatarUrl,
  );
}
