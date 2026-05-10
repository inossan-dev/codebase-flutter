import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:codebase/main.dart';

/// Tests d'intégration — s'exécutent sur un appareil réel ou émulateur.
///
/// Commande :
/// ```bash
/// flutter test integration_test/app_test.dart
/// ```
///
/// Bonnes pratiques :
/// - Tester les flux critiques de bout en bout (login, navigation, etc.)
/// - Utiliser des overrides de providers pour mocker le backend
/// - Garder les tests courts et indépendants (chacun recrée l'app)
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('démarre sur l\'écran de login quand non authentifié', (
      tester,
    ) async {
      await tester.pumpWidget(const ProviderScope(child: AppRoot()));
      await tester.pumpAndSettle();

      // Vérifier qu'on arrive bien sur le login
      expect(find.text('Connexion'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Mot de passe'), findsOneWidget);
    });

    testWidgets('affiche une erreur de validation si email vide', (
      tester,
    ) async {
      await tester.pumpWidget(const ProviderScope(child: AppRoot()));
      await tester.pumpAndSettle();

      // Taper sur "Se connecter" sans remplir
      await tester.tap(find.text('Se connecter'));
      await tester.pumpAndSettle();

      // Les messages de validation apparaissent
      expect(find.text('L\'email est requis.'), findsOneWidget);
      expect(find.text('Le mot de passe est requis.'), findsOneWidget);
    });

    testWidgets('le champ email valide le format', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: AppRoot()));
      await tester.pumpAndSettle();

      // Entrer un email invalide
      await tester.enterText(find.byType(TextFormField).first, 'not-an-email');
      await tester.tap(find.text('Se connecter'));
      await tester.pumpAndSettle();

      expect(find.text('Format d\'email invalide.'), findsOneWidget);
    });
  });
}
