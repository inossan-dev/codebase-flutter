import 'package:dio/dio.dart';

import 'package:codebase/features/auth/data/models/user_model.dart';

/// Réponse brute du endpoint /auth/login.
final class LoginResponse {
  const LoginResponse({required this.token, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    token: json['token'] as String,
    user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
  );

  final String token;
  final UserModel user;
}

/// Datasource remote : UNIQUEMENT les appels HTTP.
///
/// - Pas de logique métier ici
/// - Pas de gestion d'erreur domaine (c'est le repository qui convertit)
/// - Appels Dio explicites : clairs, testables, sans code generation
final class AuthRemoteDatasource {
  const AuthRemoteDatasource(this._dio);

  final Dio _dio;

  Future<LoginResponse> login(Map<String, dynamic> body) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: body,
    );
    return LoginResponse.fromJson(response.data!);
  }

  Future<void> logout() async {
    await _dio.post<void>('/auth/logout');
  }

  Future<UserModel> getProfile() async {
    final response = await _dio.get<Map<String, dynamic>>('/auth/me');
    return UserModel.fromJson(response.data!);
  }
}
