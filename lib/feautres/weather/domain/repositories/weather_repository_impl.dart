

// data/repositories/weather_repository_impl.dart
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:fpdart/fpdart.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../data/datasources/weather_local_data_source.dart';
import '../../data/datasources/weather_remote_datasource.dart';
import '../../domain/entities/city_entity.dart';
import '../../domain/entities/weather_entity.dart';
import '../../domain/repositories/weather_repository.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource remote;
  final WeatherLocalDataSource local;
  final NetworkInfo networkInfo;

  WeatherRepositoryImpl({
    required this.remote,
    required this.local,
    required this.networkInfo,
  });

  Future<Either<Failure, T>> _withRetry<T>(
      Future<T> Function() action, {
        int retries = 1,
      }) async {
    try {
      final result = await action();
      return Right(result);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        return const Left(CancelledFailure('Request cancelled'));
      }
      if (retries > 0) {
        await Future.delayed(const Duration(milliseconds: 800));
        return _withRetry(action, retries: retries - 1);
      }
      return Left(ServerFailure(_mapDioError(e)));
    } catch (e) {
      if (retries > 0) {
        await Future.delayed(const Duration(milliseconds: 800));
        return _withRetry(action, retries: retries - 1);
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  String _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Request timed out. Please try again.';
    }
    if (e.response?.statusCode == 429) {
      return 'Rate limit reached. Please try again later.';
    }
    if (e.response != null) {
      return 'Server error (${e.response?.statusCode}).';
    }
    return 'Something went wrong. Please check your connection.';
  }

  @override
  Future<Either<Failure, List<CityEntity>>> searchCities(
      String query, {
        CancelToken? cancelToken,
      }) async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      return const Left(NetworkFailure('No internet connection.'));
    }

    final result = await _withRetry(
          () => remote.searchCities(query, cancelToken: cancelToken),
      retries: 1,
    );

    return result.fold(
          (failure) => Left(failure),
          (cities) {
        if (cities.isEmpty) {
          return const Left(CityNotFoundFailure('No matching city found.'));
        }
        return Right(cities);
      },
    );
  }

  Future<Either<Failure, WeatherEntity>> _fetchAndCache({
    required double lat,
    required double lon,
    required String cityName,
  }) async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      return _fallbackToCache(const NetworkFailure('No internet connection.'));
    }

    final result = await _withRetry(
          () => remote.getWeatherByCoords(lat: lat, lon: lon, cityName: cityName),
      retries: 1,
    );

    return result.fold(
          (failure) => _fallbackToCache(failure),
          (weather) async {
        await local.cacheWeather(weather);
        return Right(weather);
      },
    );
  }

  Future<Either<Failure, WeatherEntity>> _fallbackToCache(Failure originalFailure) async {
    final cached = await local.getCachedWeather();
    if (cached != null) {
      return Right(cached);
    }
    return Left(originalFailure);
  }

  @override
  Future<Either<Failure, WeatherEntity>> getWeatherByCoords({
    required double lat,
    required double lon,
    required String cityName,
  }) {
    return _fetchAndCache(lat: lat, lon: lon, cityName: cityName);
  }





  Future<Either<Failure, WeatherEntity>> getWeatherByCurrentLocation() async {
    try {
      debugPrint('[Repo] getWeatherByCurrentLocation() called');
      debugPrint('[Repo] Checking location service...');
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      debugPrint('[Repo] Location service enabled: $serviceEnabled');

      if (!serviceEnabled) {
        debugPrint('[Repo] Location service is OFF, trying cache...');
        final cached = await local.getCachedWeather();
        debugPrint('[Repo] Cached weather exists: ${cached != null}');
        if (cached != null) {
          debugPrint('[Repo] Returning cached weather because GPS is OFF');
          return Right(cached);
        }
        debugPrint('[Repo] No cached weather, returning LocationFailure(service off)');
        return const Left(LocationFailure('Location services are off.'));
      }

      var permission = await Geolocator.checkPermission();
      debugPrint('[Repo] Permission: $permission');

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint('[Repo] Permission not granted, trying cache...');
        final cached = await local.getCachedWeather();
        debugPrint('[Repo] Cached weather exists: ${cached != null}');
        if (cached != null) {
          debugPrint('[Repo] Returning cached weather because permission is missing');
          return Right(cached);
        }
        debugPrint('[Repo] No cached weather, returning LocationFailure(permission)');
        return const Left(LocationFailure('Location permission not granted.'));
      }

      debugPrint('[Repo] Fetching current position...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      debugPrint(
        '[Repo] Position: ${position.latitude}, ${position.longitude}',
      );

      final result = await _fetchAndCache(
        lat: position.latitude,
        lon: position.longitude,
        cityName: 'Current location',
      );

      debugPrint('[Repo] _fetchAndCache completed');
      return result;
    } catch (e, stackTrace) {
      debugPrint('[Repo] Exception in getWeatherByCurrentLocation(): $e');
      debugPrint('[Repo] StackTrace: $stackTrace');

      final cached = await local.getCachedWeather();
      debugPrint('[Repo] Cached weather exists after exception: ${cached != null}');

      if (cached != null) {
        debugPrint('[Repo] Returning cached weather after exception');
        return Right(cached);
      }

      debugPrint('[Repo] No cache after exception, returning LocationFailure');
      return const Left(
        LocationFailure(
          'Could not access location. Enable location permission in phone settings.',
        ),
      );
    }
  }


  @override
  Future<Either<Failure, WeatherEntity>> getCachedWeatherOrFail() async {
    final cached = await local.getCachedWeather();
    if (cached != null) {
      return Right(cached);
    }
    return const Left(CacheFailure('No cached weather available.'));
  }
}