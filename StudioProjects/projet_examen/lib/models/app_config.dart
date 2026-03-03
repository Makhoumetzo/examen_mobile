/// Configuration de l'application.
/// La clé API est injectée via --dart-define à la compilation.
/// Exemple : flutter run --dart-define=OPENWEATHER_API_KEY=votre_cle_ici
class AppConfig {
  /// Clé API OpenWeatherMap.
  /// Valeur injectée via --dart-define=OPENWEATHER_API_KEY=...
  /// Ne jamais committer la vraie clé dans le dépôt.
  static const String openWeatherApiKey = String.fromEnvironment(
    'OPENWEATHER_API_KEY',
    defaultValue: 'REMPLACER_PAR_VOTRE_CLE_API',
  );
}
