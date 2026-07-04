

// domain/repositories/weather_repository.dart
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/city_entity.dart';
import '../entities/weather_entity.dart';

abstract class WeatherRepository {
  Future<Either<Failure, List<CityEntity>>> searchCities(
      String query, {
        CancelToken? cancelToken,
      });

  Future<Either<Failure, WeatherEntity>> getWeatherByCoords({
    required double lat,
    required double lon,
    required String cityName,
  });

  Future<Either<Failure, WeatherEntity>> getWeatherByCurrentLocation();

  Future<Either<Failure, WeatherEntity>> getCachedWeatherOrFail();
}