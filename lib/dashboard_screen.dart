

// lib/app/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/location/location_permission_gate.dart';
import '../feautres/weather/presentation/screens/weather_screen.dart';
import 'feautres/news/presentation/pages/widgets/news_dashboard_section.dart';
//import '../feautres/news/presentation/widgets/news_dashboard_section.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Two tabs: Weather + News
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          // Tab 0: Weather (with location permission gate)
          LocationPermissionGate(
            child: WeatherScreen(),
          ),

          // Tab 1: News dashboard
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: NewsDashboardSection(),
            ),
          ),
        ],
      ),

      // Bottom bar with only 2 items
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud_rounded),
            label: 'Weather',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_rounded),
            label: 'News',
          ),
        ],
      ),
    );
  }
}