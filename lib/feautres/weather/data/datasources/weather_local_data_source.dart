// data/datasources/weather_local_data_source.dart
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import '../models/weather_model.dart';
import '../../../../core/hive/hive_service.dart';

abstract class WeatherLocalDataSource {
  Future<void> cacheWeather(WeatherModel weather);
  Future<WeatherModel?> getCachedWeather();
}

class WeatherLocalDataSourceImpl implements WeatherLocalDataSource {
  final Box box;
  WeatherLocalDataSourceImpl(this.box);

  @override
  Future<void> cacheWeather(WeatherModel weather) async {
    final jsonString = jsonEncode(weather.toCacheJson());
    debugPrint('[Hive] Saving weather for ${weather.cityName}');
    await box.put(HiveService.weatherKey, jsonString);
  }

  @override
  Future<WeatherModel?> getCachedWeather() async {
    final raw = box.get(HiveService.weatherKey) as String?;
    if (raw == null) return null;
    debugPrint('[Hive] raw value from box: $raw');
    return WeatherModel.fromCacheJson(raw);
  }
}