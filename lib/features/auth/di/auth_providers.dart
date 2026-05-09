import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:codebase/core/di/infrastructure_providers.dart';
import 'package:codebase/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:codebase/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:codebase/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:codebase/features/auth/domain/repositories/auth_repository.dart';
import 'package:codebase/features/auth/domain/usecases/login_usecase.dart';

part 'auth_providers.g.dart';

// ─── Datasources ─────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
AuthRemoteDatasource authRemoteDatasource(Ref ref) {
  final dio = ref.watch(dioClientProvider).instance;
  return AuthRemoteDatasource(dio);
}

@Riverpod(keepAlive: true)
AuthLocalDatasource authLocalDatasource(Ref ref) {
  final storage = ref.watch(secureStorageProvider);
  return AuthLocalDatasource(storage);
}

// ─── Repositories ─────────────────────────────────────────────────────────────

/// Le provider expose l'interface [AuthRepository], pas l'implémentation.
/// Remplacer AuthRepositoryImpl par un mock en test en surchargeant ce provider.
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    remote: ref.watch(authRemoteDatasourceProvider),
    local: ref.watch(authLocalDatasourceProvider),
  );
}

// ─── UseCases ────────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
LoginUseCase loginUseCase(Ref ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
}
