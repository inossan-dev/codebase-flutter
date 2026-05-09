import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:codebase/features/auth/di/auth_providers.dart';
import 'package:codebase/core/utils/app_logger.dart';
import 'package:codebase/features/auth/domain/entities/user.dart';
import 'package:codebase/features/auth/domain/usecases/login_usecase.dart';

part 'auth_provider.g.dart';

// ─── État d'authentification global ──────────────────────────────────────────

/// Diffuse l'état d'auth en temps réel depuis le repository.
/// Utilisé par le router pour les guards de navigation.
@riverpod
Stream<User?> authState(Ref ref) {
  return ref.watch(authRepositoryProvider).watchAuthState();
}

// ─── Notifier Login ──────────────────────────────────────────────────────────

/// État du formulaire de login.
sealed class LoginState {
  const LoginState();
}
final class LoginIdle extends LoginState { const LoginIdle(); }
final class LoginLoading extends LoginState { const LoginLoading(); }
final class LoginSuccess extends LoginState {
  const LoginSuccess(this.user);
  final User user;
}
final class LoginError extends LoginState {
  const LoginError(this.message);
  final String message;
}

/// AsyncNotifier pour l'action de login.
///
/// Pourquoi AsyncNotifier plutôt que StateNotifier ?
/// - build() peut être async (chargement initial)
/// - Gestion intégrée de loading/error/data
/// - Compatible avec ref.invalidate() et ref.refresh()
@riverpod
class LoginNotifier extends _$LoginNotifier {
  @override
  LoginState build() => const LoginIdle();

  Future<void> login({
    required String email,
    required String password,
  }) async {
    if (state is LoginLoading) return; // garde anti-double-tap

    state = const LoginLoading();

    final useCase = ref.read(loginUseCaseProvider);
    final result = await useCase(
      LoginParams(email: email, password: password),
    );

    // fold : Left → erreur, Right → succès
    result.fold(
      (failure) {
        AppLogger.w('Login UI error: ${failure.message}');
        state = LoginError(failure.message);
      },
      (user) {
        AppLogger.i('Login UI success');
        state = LoginSuccess(user);
      },
    );
  }

  void resetState() => state = const LoginIdle();
}
