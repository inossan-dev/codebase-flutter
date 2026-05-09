/// Centralise toute la configuration environnementale.
///
/// Alimenté par --dart-define à la compilation.
/// NE PAS stocker de secrets ici (visibles dans le binaire).
/// Les secrets doivent passer par flutter_secure_storage.
final class AppConfig {
  AppConfig._();

  static bool _initialized = false;

  static late final String flavor;
  static late final String apiBaseUrl;

  /// Doit être appelé **une seule fois** dans main(), avant runApp().
  /// Un double appel lèvera une assertion en debug.
  static void init({
    required String flavor,
    required String apiBaseUrl,
  }) {
    assert(!_initialized, 'AppConfig.init() called more than once');
    AppConfig.flavor = flavor;
    AppConfig.apiBaseUrl = apiBaseUrl;
    _initialized = true;
  }

  static bool get isProduction => flavor == 'prod';
  static bool get isStaging => flavor == 'staging';
  static bool get isDev => flavor == 'dev';
}
