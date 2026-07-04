

// core/hive/hive_service.dart
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String weatherBox = 'weather_box';
  static const String weatherKey = 'last_weather';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(weatherBox);
  }

  static Box get weatherBoxInstance => Hive.box(weatherBox);
}