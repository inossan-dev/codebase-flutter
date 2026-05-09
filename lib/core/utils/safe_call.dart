import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import 'package:codebase/core/error/failures.dart';
import 'package:codebase/core/network/dio_client.dart';
import 'package:codebase/core/utils/app_logger.dart';

/// Wrapper générique pour les appels repository.
///
/// Élimine le boilerplate try/catch récurrent dans les repositories.
/// Gère automatiquement DioException → Failure + catch générique.
///
/// Usage dans un repository :
/// ```dart
/// @override
/// Future<Either<Failure, User>> getProfile() {
///   return safeCall(
///     action: () async {
///       final model = await _remote.getProfile();
///       return model.toDomain();
///     },
///     tag: 'getProfile',
///   );
/// }
/// ```
Future<Either<Failure, T>> safeCall<T>({
  required Future<T> Function() action,
  required String tag,
}) async {
  try {
    final result = await action();
    return Right(result);
  } on DioException catch (e, st) {
    AppLogger.e('[$tag] DioException', e, st);
    return Left(dioExceptionToFailure(e));
  } catch (e, st) {
    AppLogger.e('[$tag] Unexpected error', e, st);
    return const Left(UnexpectedFailure());
  }
}
