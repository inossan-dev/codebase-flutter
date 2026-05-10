import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:codebase/core/error/failures.dart';
import 'package:codebase/core/usecase/usecase.dart';
import 'package:codebase/features/auth/domain/entities/user.dart';
import 'package:codebase/features/auth/domain/repositories/auth_repository.dart';

/// UseCase : un seul cas d'utilisation, une seule responsabilité.
///
/// Avantages :
/// - Testable de façon isolée sans dépendance UI ni réseau
/// - La logique métier (validation, règles) reste dans le domaine
/// - Le UseCase peut être composé d'autres UseCases
final class LoginUseCase extends UseCase<User, LoginParams> {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, User>> call(LoginParams params) {
    // Validation domaine (règles métier, pas UI)
    if (!_isValidEmail(params.email)) {
      return Future.value(const Left(ValidationFailure('Email invalide.')));
    }
    if (params.password.length < 8) {
      return Future.value(
        const Left(
          ValidationFailure(
            'Le mot de passe doit contenir au moins 8 caractères.',
          ),
        ),
      );
    }

    return _repository.login(email: params.email, password: params.password);
  }

  static bool _isValidEmail(String email) {
    return RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }
}

/// Paramètres typés plutôt qu'une liste de positionnels.
/// Évite les erreurs d'ordre d'argument et facilite l'évolution.
final class LoginParams extends Equatable {
  const LoginParams({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}
