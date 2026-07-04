// lib/features/weather/data/datasources/weather_remote_data_source.dart

import 'package:dio/dio.dart';

import '../models/city_model.dart';
import '../models/weather_model.dart';

abstract class WeatherRemoteDataSource {
  Future<List<CityModel>> searchCities(
      String query, {
        CancelToken? cancelToken,
      });

  Future<WeatherModel> getWeatherByCoords({
    required double lat,
    required double lon,
    required String cityName,
  });
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final Dio dio;

  WeatherRemoteDataSourceImpl(this.dio);

  static const String _geoBase =
      'https://geocoding-api.open-meteo.com/v1/search';

  static const String _forecastBase =
      'https://api.open-meteo.com/v1/forecast';

  @override
  Future<List<CityModel>> searchCities(
      String query, {
        CancelToken? cancelToken,
      }) async {
    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty || trimmedQuery.length < 2) {
      return [];
    }

    final response = await dio.get(
      _geoBase,
      cancelToken: cancelToken,
      queryParameters: {
        'name': trimmedQuery,
        'count': 10,
        'language': 'en',
        'format': 'json',
      },
    );

    final results = response.data['results'] as List?;

    if (results == null || results.isEmpty) {
      return [];
    }

    return results
        .map((e) => CityModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<WeatherModel> getWeatherByCoords({
    required double lat,
    required double lon,
    required String cityName,
  }) async {
    final response = await dio.get(
      _forecastBase,
      queryParameters: {
        'latitude': lat,
        'longitude': lon,
        'current_weather': true,
        'hourly': 'temperature_2m,relative_humidity_2m,weathercode',
        'daily': 'temperature_2m_max,temperature_2m_min,weathercode',
        'timezone': 'auto',
      },
    );

    return WeatherModel.fromOpenMeteo(
      json: Map<String, dynamic>.from(response.data),
      cityName: cityName,
    );
  }
}