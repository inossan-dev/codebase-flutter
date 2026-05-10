import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:codebase/features/auth/presentation/providers/auth_provider.dart';
import 'package:codebase/features/auth/presentation/screens/login_screen.dart';

// ─── Mocks ───────────────────────────────────────────────────────────────────

class MockLoginNotifier extends LoginNotifier with Mock {
  @override
  LoginState build() => const LoginIdle();
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

/// Wrap minimal pour tester les widgets qui utilisent Riverpod et go_router.
Widget testableWidget({
  required Widget child,
  List<Override> overrides = const [],
}) {
  final router = GoRouter(
    routes: [GoRoute(path: '/', builder: (_, __) => child)],
  );

  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(routerConfig: router),
  );
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  group('LoginScreen', () {
    testWidgets('affiche le formulaire dans l\'état initial', (tester) async {
      await tester.pumpWidget(testableWidget(child: const LoginScreen()));

      expect(find.text('Connexion'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Mot de passe'), findsOneWidget);
      expect(find.text('Se connecter'), findsOneWidget);
    });

    testWidgets('valide le formulaire avant de soumettre', (tester) async {
      await tester.pumpWidget(testableWidget(child: const LoginScreen()));

      // Cliquer sans remplir le formulaire
      await tester.tap(find.text('Se connecter'));
      await tester.pumpAndSettle();

      // Les messages de validation doivent apparaître
      expect(find.text('L\'email est requis.'), findsOneWidget);
      expect(find.text('Le mot de passe est requis.'), findsOneWidget);
    });

    testWidgets('affiche un CircularProgressIndicator en état loading', (
      tester,
    ) async {
      final mockNotifier = MockLoginNotifier();

      await tester.pumpWidget(
        testableWidget(
          overrides: [
            // Override du provider avec un état loading
            loginNotifierProvider.overrideWith(() => mockNotifier),
          ],
          child: const LoginScreen(),
        ),
      );

      // Simuler l'état loading
      mockNotifier.state = const LoginLoading();
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Le bouton doit être désactivé
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });
  });
}
