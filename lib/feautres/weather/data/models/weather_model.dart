// data/models/weather_model.dart
import 'dart:convert';
import '../../domain/entities/weather_entity.dart';

class WeatherModel extends WeatherEntity {
  const WeatherModel({
    required super.cityName,
    required super.currentTemp,
    required super.weatherCode,
    required super.windSpeed,
    required super.humidity,
    required super.forecast,
    required super.hourlyForecast,
    required super.fetchedAt,
    super.isFromCache = false,
  });

  factory WeatherModel.fromOpenMeteo({
    required Map<String, dynamic> json,
    required String cityName,
  }) {
    final current = json['current_weather'] as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>;
    final hourly = json['hourly'] as Map<String, dynamic>;

    final hourlyTimes = (hourly['time'] as List).cast<String>();
    final hourlyHumidity = (hourly['relative_humidity_2m'] as List).cast<num>();
    final hourlyTemps = (hourly['temperature_2m'] as List).cast<num>();
    final hourlyCodes = (hourly['weathercode'] as List).cast<num>();

    final currentTime = current['time'] as String;
    int currentIndex = hourlyTimes.indexOf(currentTime);
    if (currentIndex == -1) currentIndex = 0;

    final humidity = hourlyHumidity[currentIndex].toInt();

    final hourlyForecast = <HourlyForecastEntity>[];
    final endIndex = (currentIndex + 6).clamp(0, hourlyTimes.length);
    for (int i = currentIndex; i < endIndex; i++) {
      hourlyForecast.add(
        HourlyForecastEntity(
          time: DateTime.parse(hourlyTimes[i]),
          temp: hourlyTemps[i].toDouble(),
          weatherCode: hourlyCodes[i].toInt(),
        ),
      );
    }

    final dates = (daily['time'] as List).cast<String>();
    final maxTemps = (daily['temperature_2m_max'] as List).cast<num>();
    final minTemps = (daily['temperature_2m_min'] as List).cast<num>();
    final codes = (daily['weathercode'] as List).cast<num>();

    final forecast = List.generate(dates.length, (i) {
      return DailyForecastEntity(
        date: DateTime.parse(dates[i]),
        maxTemp: maxTemps[i].toDouble(),
        minTemp: minTemps[i].toDouble(),
        weatherCode: codes[i].toInt(),
      );
    });

    return WeatherModel(
      cityName: cityName,
      currentTemp: (current['temperature'] as num).toDouble(),
      weatherCode: (current['weathercode'] as num).toInt(),
      windSpeed: (current['windspeed'] as num).toDouble(),
      humidity: humidity,
      forecast: forecast,
      hourlyForecast: hourlyForecast,
      fetchedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toCacheJson() {
    return {
      'cityName': cityName,
      'currentTemp': currentTemp,
      'weatherCode': weatherCode,
      'windSpeed': windSpeed,
      'humidity': humidity,
      'fetchedAt': fetchedAt.toIso8601String(),
      'forecast': forecast
          .map((f) => {
        'date': f.date.toIso8601String(),
        'maxTemp': f.maxTemp,
        'minTemp': f.minTemp,
        'weatherCode': f.weatherCode,
      })
          .toList(),
      'hourlyForecast': hourlyForecast
          .map((h) => {
        'time': h.time.toIso8601String(),
        'temp': h.temp,
        'weatherCode': h.weatherCode,
      })
          .toList(),
    };
  }

  factory WeatherModel.fromCacheJson(String rawJson) {
    final json = jsonDecode(rawJson) as Map<String, dynamic>;

    final forecastList = (json['forecast'] as List)
        .map((f) => DailyForecastEntity(
      date: DateTime.parse(f['date']),
      maxTemp: (f['maxTemp'] as num).toDouble(),
      minTemp: (f['minTemp'] as num).toDouble(),
      weatherCode: (f['weatherCode'] as num).toInt(),
    ))
        .toList();

    final hourlyList = (json['hourlyForecast'] as List)
        .map((h) => HourlyForecastEntity(
      time: DateTime.parse(h['time']),
      temp: (h['temp'] as num).toDouble(),
      weatherCode: (h['weatherCode'] as num).toInt(),
    ))
        .toList();

    return WeatherModel(
      cityName: json['cityName'],
      currentTemp: (json['currentTemp'] as num).toDouble(),
      weatherCode: (json['weatherCode'] as num).toInt(),
      windSpeed: (json['windSpeed'] as num).toDouble(),
      humidity: (json['humidity'] as num).toInt(),
      fetchedAt: DateTime.parse(json['fetchedAt']),
      forecast: forecastList,
      hourlyForecast: hourlyList,
      isFromCache: true,
    );
  }
}