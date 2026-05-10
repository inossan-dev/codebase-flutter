// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Codebase';

  @override
  String get login => 'Connexion';

  @override
  String get loginSubtitle => 'Bienvenue ! Entrez vos identifiants.';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'vous@example.com';

  @override
  String get emailRequired => 'L\'email est requis.';

  @override
  String get emailInvalid => 'Format d\'email invalide.';

  @override
  String get password => 'Mot de passe';

  @override
  String get passwordRequired => 'Le mot de passe est requis.';

  @override
  String passwordMinLength(int min) {
    return 'Le mot de passe doit contenir au moins $min caractères.';
  }

  @override
  String get signIn => 'Se connecter';

  @override
  String get logout => 'Déconnexion';

  @override
  String get home => 'Accueil';

  @override
  String get welcome => 'Bienvenue !';

  @override
  String get codebaseReady => 'Votre codebase est prête.';

  @override
  String get notFound => 'Page introuvable';

  @override
  String get notFoundCode => '404';

  @override
  String get back => 'Retour';

  @override
  String get networkError => 'Erreur réseau. Vérifiez votre connexion.';

  @override
  String get serverError => 'Erreur serveur. Réessayez plus tard.';

  @override
  String get unexpectedError => 'Une erreur inattendue est survenue.';

  @override
  String get noConnection => 'Aucune connexion internet.';

  @override
  String get connectionRestored => 'Connexion rétablie.';
}
