// ignore_for_file: avoid_void_async
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:codebase/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:codebase/core/di/providers.dart';
import 'package:codebase/core/router/app_router.dart';
import 'package:codebase/core/theme/app_theme.dart';
import 'package:codebase/core/utils/app_logger.dart';
import 'package:codebase/core/config/app_config.dart';

/// Point d'entrée unique.
/// - dart-define permet d'injecter l'env sans toucher au code.
/// - ProviderScope englobe TOUT pour que Riverpod soit disponible partout.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ─── Orientation forcée (adapter selon besoin) ────────────────────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ─── Config via dart-define ───────────────────────────────────────────────
  // Usage : flutter run --dart-define=FLAVOR=staging --dart-define=API_URL=https://...
  AppConfig.init(
    flavor: const String.fromEnvironment('FLAVOR', defaultValue: 'dev'),
    apiBaseUrl: const String.fromEnvironment(
      'API_URL',
      defaultValue: 'https://api.dev.example.com',
    ),
  );

  AppLogger.init(flavor: AppConfig.flavor);
  AppLogger.i('App starting | flavor=${AppConfig.flavor}');

  runApp(
    // ProviderScope au niveau le plus haut → pas de UnprovisionedWidgetError
    const ProviderScope(child: AppRoot()),
  );
}

class AppRoot extends ConsumerWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Codebase',
      debugShowCheckedModeBanner: false,

      // ─── Thème ────────────────────────────────────────────────────────────
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,

      // ─── Navigation ───────────────────────────────────────────────────────
      routerConfig: router,

      // ─── Localisation ─────────────────────────────────────────────────────
      locale: const Locale('fr'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
