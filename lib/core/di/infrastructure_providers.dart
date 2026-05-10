import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:codebase/core/network/dio_client.dart';

part 'infrastructure_providers.g.dart';

// ─── Infrastructure ──────────────────────────────────────────────────────────
// Providers transversaux utilisés par toutes les features.

@Riverpod(keepAlive: true)
FlutterSecureStorage secureStorage(Ref ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
}

@Riverpod(keepAlive: true)
DioClient dioClient(Ref ref) {
  final storage = ref.watch(secureStorageProvider);
  return DioClient(storage: storage);
}

// ─── Theme ───────────────────────────────────────────────────────────────────

/// Provider du ThemeMode global, modifiable depuis n'importe quel widget.
@Riverpod(keepAlive: true)
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() => ThemeMode.system;

  void setLight() => state = ThemeMode.light;
  void setDark() => state = ThemeMode.dark;
  void setSystem() => state = ThemeMode.system;
  void toggle() =>
      state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
}
