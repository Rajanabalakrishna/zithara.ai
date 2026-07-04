// domain/entities/weather_entity.dart
import 'package:equatable/equatable.dart';

class HourlyForecastEntity extends Equatable {
  final DateTime time;
  final double temp;
  final int weatherCode;

  const HourlyForecastEntity({
    required this.time,
    required this.temp,
    required this.weatherCode,
  });

  @override
  List<Object?> get props => [time, temp, weatherCode];
}

class DailyForecastEntity extends Equatable {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final int weatherCode;

  const DailyForecastEntity({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.weatherCode,
  });

  @override
  List<Object?> get props => [date, maxTemp, minTemp, weatherCode];
}

class WeatherEntity extends Equatable {
  final String cityName;
  final double currentTemp;
  final int weatherCode;
  final double windSpeed;
  final int humidity;
  final List<DailyForecastEntity> forecast;
  final List<HourlyForecastEntity> hourlyForecast;
  final DateTime fetchedAt;
  final bool isFromCache;

  const WeatherEntity({
    required this.cityName,
    required this.currentTemp,
    required this.weatherCode,
    required this.windSpeed,
    required this.humidity,
    required this.forecast,
    required this.hourlyForecast,
    required this.fetchedAt,
    this.isFromCache = false,
  });

  WeatherEntity copyWith({bool? isFromCache}) {
    return WeatherEntity(
      cityName: cityName,
      currentTemp: currentTemp,
      weatherCode: weatherCode,
      windSpeed: windSpeed,
      humidity: humidity,
      forecast: forecast,
      hourlyForecast: hourlyForecast,
      fetchedAt: fetchedAt,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  @override
  List<Object?> get props => [
    cityName,
    currentTemp,
    weatherCode,
    windSpeed,
    humidity,
    forecast,
    hourlyForecast,
    fetchedAt,
    isFromCache,
  ];
}

/// Maps Open-Meteo WMO weather codes to the condition keys used by the UI
/// (sunny / partly_cloudy / cloudy / rainy / thunderstorm).
String conditionKeyFromCode(int code) {
  if (code == 0) return 'sunny';
  if (code <= 3) return 'partly_cloudy';
  if (code <= 49) return 'cloudy';
  if (code <= 69) return 'rainy';
  if (code <= 79) return 'cloudy';
  if (code <= 84) return 'rainy';
  if (code <= 99) return 'thunderstorm';
  return 'cloudy';
}

String weatherCodeToLabel(int code) {
  if (code == 0) return 'Clear Sky';
  if (code <= 3) return 'Partly Cloudy';
  if (code <= 49) return 'Foggy';
  if (code <= 59) return 'Drizzle';
  if (code <= 69) return 'Rain';
  if (code <= 79) return 'Snow';
  if (code <= 84) return 'Rain Showers';
  if (code <= 99) return 'Thunderstorm';
  return 'Unknown';
}