class CurrentWeather {
  const CurrentWeather({
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
    required this.updatedAt,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    if (current is! Map<String, dynamic>) {
      throw const FormatException('Data cuaca Open-Meteo tidak valid.');
    }
    return CurrentWeather(
      temperature: _requiredNumber(current, 'temperature_2m'),
      apparentTemperature: _optionalNumber(current, 'apparent_temperature'),
      humidity: _optionalNumber(current, 'relative_humidity_2m'),
      windSpeed: _optionalNumber(current, 'wind_speed_10m'),
      weatherCode: _optionalNumber(current, 'weather_code')?.toInt(),
      updatedAt: _optionalString(current, 'time'),
    );
  }

  final double temperature;
  final double? apparentTemperature;
  final double? humidity;
  final double? windSpeed;
  final int? weatherCode;
  final String? updatedAt;

  String get condition => switch (weatherCode) {
    0 => 'Cerah',
    1 || 2 => 'Cerah berawan',
    3 => 'Berawan',
    45 || 48 => 'Berkabut',
    51 || 53 || 55 || 56 || 57 => 'Gerimis',
    61 || 63 || 65 || 66 || 67 => 'Hujan',
    71 || 73 || 75 || 77 => 'Salju',
    80 || 81 || 82 => 'Hujan sesaat',
    85 || 86 => 'Hujan salju sesaat',
    95 || 96 || 99 => 'Badai petir',
    _ => 'Kondisi cuaca tidak diketahui',
  };
}

class CurrentAirQuality {
  const CurrentAirQuality({
    required this.usAqi,
    required this.pm25,
    required this.pm10,
    required this.updatedAt,
  });

  factory CurrentAirQuality.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    if (current is! Map<String, dynamic>) {
      throw const FormatException(
        'Data kualitas udara Open-Meteo tidak valid.',
      );
    }
    return CurrentAirQuality(
      usAqi: _requiredNumber(current, 'us_aqi'),
      pm25: _optionalNumber(current, 'pm2_5'),
      pm10: _optionalNumber(current, 'pm10'),
      updatedAt: _optionalString(current, 'time'),
    );
  }

  final double usAqi;
  final double? pm25;
  final double? pm10;
  final String? updatedAt;

  String get category => switch (usAqi) {
    <= 50 => 'Baik',
    <= 100 => 'Sedang',
    <= 150 => 'Tidak sehat bagi kelompok sensitif',
    <= 200 => 'Tidak sehat',
    <= 300 => 'Sangat tidak sehat',
    _ => 'Berbahaya',
  };
}

double _requiredNumber(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is num) return value.toDouble();
  throw FormatException('Field $key pada data Open-Meteo tidak valid.');
}

double? _optionalNumber(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is num) return value.toDouble();
  throw FormatException('Field $key pada data Open-Meteo tidak valid.');
}

String? _optionalString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is String) return value;
  throw FormatException('Field $key pada data Open-Meteo tidak valid.');
}
