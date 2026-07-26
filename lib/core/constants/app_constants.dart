abstract final class AppConstants {
  static const String villageName = 'Saint-Martin-de-Belleville';
  // L'app est dédiée à une seule commune pour l'instant (cf. docs/ROADMAP.md) ;
  // identifiant stable côté civic_api, distinct du nom affiché ci-dessus.
  static const String communeSlug = 'saint-martin-de-belleville';
  static const int homeArticlesCount = 3;
  static const String openWeatherMapBaseUrl =
      'https://api.openweathermap.org/data/2.5';
  static const List<String> municipalServices = [
    'État Civil',
    'Urbanisme',
    'Services Techniques',
    'Accueil Général',
  ];
}
