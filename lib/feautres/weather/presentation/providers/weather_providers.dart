// presentation/providers/weather_providers.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/hive/hive_service.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/network_info.dart';
import '../../data/datasources/weather_local_data_source.dart';
//import '../../data/datasources/weather_remote_data_source.dart';
import '../../data/datasources/weather_remote_datasource.dart';
//import '../../data/repositories/weather_repository_impl.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../domain/repositories/weather_repository_impl.dart';

final dioProvider = Provider<Dio>((ref) => DioClient.create());

final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(ref.watch(connectivityProvider));
});

final weatherRemoteDataSourceProvider = Provider<WeatherRemoteDataSource>((ref) {
  return WeatherRemoteDataSourceImpl(ref.watch(dioProvider));
});

final weatherLocalDataSourceProvider = Provider<WeatherLocalDataSource>((ref) {
  return WeatherLocalDataSourceImpl(HiveService.weatherBoxInstance);
});

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepositoryImpl(
    remote: ref.watch(weatherRemoteDataSourceProvider),
    local: ref.watch(weatherLocalDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});