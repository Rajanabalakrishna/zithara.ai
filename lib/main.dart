import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app_bootstrap.dart';
import 'app/theme/app_theme.dart';
import 'core/hive/hive_service.dart';
import 'core/location/location_permission_gate.dart';
import 'dashboard_screen.dart';
import 'feautres/news/presentation/pages/bookmarks_page.dart';
import 'feautres/weather/presentation/screens/weather_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app_bootstrap.dart';
import 'app/theme/app_theme.dart';
import 'core/hive/hive_service.dart';
import 'feautres/news/presentation/pages/bookmarks_page.dart';
import 'feautres/weather/presentation/screens/weather_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  await bootstrapApp();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News & Weather hub',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const WeatherScreen(), // Set WeatherScreen as the initial screen

    );
  }
}


