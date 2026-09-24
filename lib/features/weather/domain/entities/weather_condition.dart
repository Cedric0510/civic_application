enum WeatherCondition {
  clear,
  partlyCloudy,
  cloudy,
  rain,
  storm,
  snow,
  mist;

  static WeatherCondition fromIconCode(String code) {
    final prefix = code.length >= 2 ? code.substring(0, 2) : '';
    return switch (prefix) {
      '01' => clear,
      '02' || '03' => partlyCloudy,
      '04' => cloudy,
      '09' || '10' => rain,
      '11' => storm,
      '13' => snow,
      _ => mist,
    };
  }
}

bool isNightIconCode(String code) => code.endsWith('n');

String dayVariantOfIconCode(String code) =>
    code.length >= 2 ? '${code.substring(0, 2)}d' : code;
