// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Codebase';

  @override
  String get login => 'Login';

  @override
  String get loginSubtitle => 'Welcome! Enter your credentials.';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get emailRequired => 'Email is required.';

  @override
  String get emailInvalid => 'Invalid email format.';

  @override
  String get password => 'Password';

  @override
  String get passwordRequired => 'Password is required.';

  @override
  String passwordMinLength(int min) {
    return 'Password must be at least $min characters.';
  }

  @override
  String get signIn => 'Sign in';

  @override
  String get logout => 'Log out';

  @override
  String get home => 'Home';

  @override
  String get welcome => 'Welcome!';

  @override
  String get codebaseReady => 'Your codebase is ready.';

  @override
  String get notFound => 'Page not found';

  @override
  String get notFoundCode => '404';

  @override
  String get back => 'Back';

  @override
  String get networkError => 'Network error. Check your connection.';

  @override
  String get serverError => 'Server error. Try again later.';

  @override
  String get unexpectedError => 'An unexpected error occurred.';

  @override
  String get noConnection => 'No internet connection.';

  @override
  String get connectionRestored => 'Connection restored.';
}
