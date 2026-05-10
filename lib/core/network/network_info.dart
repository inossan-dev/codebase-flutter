import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:codebase/core/utils/app_logger.dart';

part 'network_info.g.dart';

/// Service de connectivité réseau.
///
/// Usage dans un widget :
/// ```dart
/// final isOnline = ref.watch(isOnlineProvider);
/// ```
///
/// Usage dans un repository :
/// ```dart
/// final networkInfo = ref.read(networkInfoProvider);
/// if (!await networkInfo.isConnected) return Left(NetworkFailure());
/// ```
final class NetworkInfo {
  const NetworkInfo(this._connectivity);

  final Connectivity _connectivity;

  /// Vérifie la connectivité actuelle.
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  /// Stream des changements de connectivité.
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(
      (results) => !results.contains(ConnectivityResult.none),
    );
  }
}

// ─── Providers ───────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
Connectivity connectivity(Ref ref) => Connectivity();

@Riverpod(keepAlive: true)
NetworkInfo networkInfo(Ref ref) {
  return NetworkInfo(ref.watch(connectivityProvider));
}

/// Provider réactif : émet true/false selon la connexion.
/// Utilise `ref.watch(isOnlineProvider)` dans les widgets pour réagir.
@riverpod
Stream<bool> isOnline(Ref ref) {
  final networkInfo = ref.watch(networkInfoProvider);

  return networkInfo.onConnectivityChanged.map((isConnected) {
    if (isConnected) {
      AppLogger.i('Connection restored');
    } else {
      AppLogger.w('Connection lost');
    }
    return isConnected;
  });
}
