enum AppModule {
  articles('ARTICLES'),
  polls('POLLS'),
  services('SERVICES'),
  appointments('APPOINTMENTS'),
  commerces('COMMERCES'),
  reports('REPORTS'),
  weather('WEATHER');

  const AppModule(this.apiName);

  final String apiName;

  static AppModule? fromApiName(String apiName) {
    for (final module in values) {
      if (module.apiName == apiName) return module;
    }
    return null;
  }
}
