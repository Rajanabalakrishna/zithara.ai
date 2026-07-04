import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/location/location_permission_controller.dart';
import '../../../../core/location/location_permission_state.dart';
import '../../domain/entities/weather_entity.dart';
import '../providers/weather_controller.dart';
import '../providers/city_search_controller.dart';

/// Atmosphere — full weather dashboard screen.
/// Single-file implementation: no separate widget files.
/// Wired to Riverpod controllers; UI/layout kept exactly as designed.
class WeatherScreen extends ConsumerStatefulWidget {
  const WeatherScreen({super.key});

  @override
  ConsumerState<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends ConsumerState<WeatherScreen> {
  int _navIndex = 0;


  @override
  void initState() {
    super.initState();
  }

  IconData _iconFor(String condition) {
    switch (condition) {
      case 'sunny':
        return Icons.wb_sunny_rounded;
      case 'partly_cloudy':
        return Icons.wb_cloudy_rounded;
      case 'cloudy':
        return Icons.cloud_rounded;
      case 'rainy':
        return Icons.grain_rounded;
      case 'thunderstorm':
        return Icons.thunderstorm_rounded;
      default:
        return Icons.wb_sunny_rounded;
    }
  }

  Color _colorFor(String condition, ColorScheme scheme) {
    switch (condition) {
      case 'sunny':
      case 'partly_cloudy':
        return AppTheme.sunAccent;
      case 'rainy':
        return scheme.primary;
      case 'thunderstorm':
        return scheme.onSurface;
      case 'cloudy':
      default:
        return scheme.outline;
    }
  }

  BoxDecoration _glassDecoration(bool isDark, double radius) {
    return BoxDecoration(
      color: isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.7),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: isDark ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.4),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
          blurRadius: 32,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  Widget _glassCard({
    required Widget child,
    required bool isDark,
    double radius = AppTheme.radiusMd,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: _glassDecoration(isDark, radius),
          child: child,
        ),
      ),
    );
  }

  String _formatDayLabel(DateTime date, int index) {
    if (index == 0) return 'Tomorrow';
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return days[date.weekday - 1];
  }

  String _formatHourLabel(DateTime time, bool isNow) {
    if (isNow) return 'Now';
    final hour = time.hour.toString().padLeft(2, '0');
    return '$hour:00';
  }

  void _openSearchSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CitySearchSheet(isDark: isDark),
    );
  }

  @override
  Widget build(BuildContext context) {

    ref.listen<LocationPermissionUiState>(
      locationPermissionControllerProvider,
          (previous, next) {
        if (next.status == LocationPermissionStatus.granted &&
            previous?.status != LocationPermissionStatus.granted) {
          ref.read(weatherControllerProvider.notifier).loadCurrentLocationWeather();
        }
      },
    );
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final backgroundAsset = AppTheme.backgroundAsset(brightness);

    final weatherState = ref.watch(weatherControllerProvider);
    final weather = weatherState.weather;

    final location = weather?.cityName ?? 'Fetching location…';
    final currentTemp = weather?.currentTemp.round() ?? 0;
    final currentCondition =
    weather != null ? conditionKeyFromCode(weather.weatherCode) : 'sunny';
    final currentDescription =
    weather != null ? weatherCodeToLabel(weather.weatherCode) : '—';
    final high = weather?.forecast.isNotEmpty == true
        ? weather!.forecast.first.maxTemp.round()
        : 0;
    final low = weather?.forecast.isNotEmpty == true
        ? weather!.forecast.first.minTemp.round()
        : 0;
    final humidity = weather?.humidity ?? 0;
    final windSpeed = weather?.windSpeed ?? 0;

    final hourly = weather?.hourlyForecast ?? const <HourlyForecastEntity>[];
    final daily = weather != null && weather.forecast.length > 1
        ? weather.forecast.sublist(1, weather.forecast.length.clamp(0, 6))
        : const <DailyForecastEntity>[];

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            backgroundAsset,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(color: Theme.of(context).scaffoldBackgroundColor);
            },
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                  Colors.black.withOpacity(0.35),
                  Colors.transparent,
                  Colors.black.withOpacity(0.55),
                ]
                    : [
                  Colors.white.withOpacity(0.05),
                  Colors.transparent,
                  Colors.white.withOpacity(0.10),
                ],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 640;
                return Column(
                  children: [
                    ClipRRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.08)
                                : Colors.white.withOpacity(0.10),
                            border: Border(
                              bottom: BorderSide(color: Colors.white.withOpacity(0.2)),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          child: Row(
                            children: [
                              Material(
                                color: Colors.transparent,
                                shape: const CircleBorder(),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: () {
                                    ref
                                        .read(weatherControllerProvider.notifier)
                                        .loadCurrentLocationWeather();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Icon(Icons.my_location_rounded,
                                        color: Colors.white.withOpacity(0.85)),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'Atmosphere',
                                style: textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Material(
                                color: Colors.transparent,
                                shape: const CircleBorder(),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: () => _openSearchSheet(context, isDark),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Icon(Icons.search_rounded,
                                        color: Colors.white.withOpacity(0.85)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (weatherState.errorMessage != null)
                      Container(
                        width: double.infinity,
                        color: Colors.red.withOpacity(0.15),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          weatherState.errorMessage!,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                    if (weatherState.showingOfflineData && weather != null)
                      Container(
                        width: double.infinity,
                        color: Colors.orange.withOpacity(0.15),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          'Showing offline data from ${TimeOfDay.fromDateTime(weather.fetchedAt).format(context)}',
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => ref
                            .read(weatherControllerProvider.notifier)
                            .refresh(),
                        child: Stack(
                          children: [
                            SingleChildScrollView(
                              padding: EdgeInsets.symmetric(
                                horizontal: isWide ? 32 : AppTheme.gutter,
                                vertical: 24,
                              ).copyWith(bottom: 120),
                              child: Center(
                                child: ConstrainedBox(
                                  constraints:
                                  BoxConstraints(maxWidth: isWide ? 720 : double.infinity),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      _glassCard(
                                        isDark: isDark,
                                        radius: AppTheme.radiusMd,
                                        child: Row(
                                          children: [
                                            Icon(Icons.location_on_rounded,
                                                color: colorScheme.outline),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('CURRENT LOCATION',
                                                      style: textTheme.labelSmall),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    location,
                                                    style: textTheme.headlineMedium,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      _glassCard(
                                        isDark: isDark,
                                        radius: AppTheme.radiusXl,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 32, horizontal: 16),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          clipBehavior: Clip.none,
                                          children: [
                                            Positioned(
                                              top: -60,
                                              right: -40,
                                              child: Container(
                                                width: 180,
                                                height: 180,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: AppTheme.sunAccent.withOpacity(0.35),
                                                ),
                                              ),
                                            ),
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  _iconFor(currentCondition),
                                                  size: 56,
                                                  color: _colorFor(currentCondition, colorScheme),
                                                ),
                                                const SizedBox(height: 8),
                                                FittedBox(
                                                  child: Text('$currentTemp°',
                                                      style: textTheme.displayLarge),
                                                ),
                                                Text(
                                                  currentDescription,
                                                  style: textTheme.headlineMedium?.copyWith(
                                                    color:
                                                    colorScheme.onSurface.withOpacity(0.8),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'H:$high° L:$low°',
                                                  style: textTheme.bodyMedium?.copyWith(
                                                    color: colorScheme.onSurfaceVariant,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      GridView.count(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        crossAxisCount: isWide ? 4 : 2,
                                        crossAxisSpacing: AppTheme.cardGap,
                                        mainAxisSpacing: AppTheme.cardGap,
                                        childAspectRatio: 1.15,
                                        children: [
                                          _metricCard(
                                            icon: Icons.water_drop_rounded,
                                            label: 'HUMIDITY',
                                            value: '$humidity%',
                                            sub: humidity > 70 ? 'High levels' : 'Normal levels',
                                            isDark: isDark,
                                            colorScheme: colorScheme,
                                            textTheme: textTheme,
                                          ),
                                          _metricCard(
                                            icon: Icons.air_rounded,
                                            label: 'WIND',
                                            value: '${windSpeed.round()} km/h',
                                            sub: windSpeed > 20 ? 'Strong breeze' : 'Light breeze',
                                            isDark: isDark,
                                            colorScheme: colorScheme,
                                            textTheme: textTheme,
                                          ),
                                          _metricCard(
                                            icon: Icons.visibility_rounded,
                                            label: 'VISIBILITY',
                                            value: '10 km',
                                            sub: 'Clear',
                                            isDark: isDark,
                                            colorScheme: colorScheme,
                                            textTheme: textTheme,
                                          ),
                                          _metricCard(
                                            icon: Icons.light_mode_rounded,
                                            label: 'UV INDEX',
                                            value: '2',
                                            sub: 'Low',
                                            isDark: isDark,
                                            colorScheme: colorScheme,
                                            textTheme: textTheme,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 24),
                                      _glassCard(
                                        isDark: isDark,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("TODAY'S FORECAST", style: textTheme.labelSmall),
                                            const SizedBox(height: 12),
                                            SizedBox(
                                              height: 96,
                                              child: hourly.isEmpty
                                                  ? Center(
                                                child: Text(
                                                  'No hourly data',
                                                  style: TextStyle(
                                                      color: colorScheme.onSurfaceVariant),
                                                ),
                                              )
                                                  : ListView.separated(
                                                scrollDirection: Axis.horizontal,
                                                itemCount: hourly.length,
                                                separatorBuilder: (_, __) =>
                                                const SizedBox(width: 12),
                                                itemBuilder: (context, i) {
                                                  final item = hourly[i];
                                                  final isNow = i == 0;
                                                  final conditionKey =
                                                  conditionKeyFromCode(item.weatherCode);
                                                  return Container(
                                                    width: 64,
                                                    padding: const EdgeInsets.symmetric(
                                                        vertical: 12, horizontal: 8),
                                                    decoration: BoxDecoration(
                                                      color: isNow
                                                          ? colorScheme.primary
                                                          .withOpacity(0.12)
                                                          : Colors.transparent,
                                                      borderRadius:
                                                      BorderRadius.circular(999),
                                                      border: isNow
                                                          ? Border.all(
                                                          color: colorScheme.primary
                                                              .withOpacity(0.3))
                                                          : null,
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(
                                                          _formatHourLabel(
                                                              item.time, isNow),
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight: isNow
                                                                ? FontWeight.w600
                                                                : FontWeight.w400,
                                                            color: isNow
                                                                ? colorScheme.primary
                                                                : colorScheme
                                                                .onSurfaceVariant,
                                                          ),
                                                        ),
                                                        Icon(
                                                          _iconFor(conditionKey),
                                                          size: 24,
                                                          color: _colorFor(
                                                              conditionKey, colorScheme),
                                                        ),
                                                        Text(
                                                          '${item.temp.round()}°',
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.w700,
                                                            color: colorScheme.onSurface,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      _glassCard(
                                        isDark: isDark,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.calendar_month_rounded,
                                                    size: 20,
                                                    color: colorScheme.onSurfaceVariant),
                                                const SizedBox(width: 8),
                                                Text('NEXT 5 DAYS', style: textTheme.labelSmall),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            if (daily.isEmpty)
                                              Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 12),
                                                child: Text(
                                                  'Forecast unavailable',
                                                  style: TextStyle(
                                                      color: colorScheme.onSurfaceVariant),
                                                ),
                                              )
                                            else
                                              for (int i = 0; i < daily.length; i++) ...[
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.symmetric(vertical: 10),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 3,
                                                        child: Text(
                                                          _formatDayLabel(daily[i].date, i),
                                                          style: TextStyle(
                                                            fontWeight: i == 0
                                                                ? FontWeight.w600
                                                                : FontWeight.w400,
                                                            color: i == 0
                                                                ? colorScheme.onSurface
                                                                : colorScheme.onSurfaceVariant,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 2,
                                                        child: Center(
                                                          child: Icon(
                                                            _iconFor(conditionKeyFromCode(
                                                                daily[i].weatherCode)),
                                                            size: 22,
                                                            color: _colorFor(
                                                                conditionKeyFromCode(
                                                                    daily[i].weatherCode),
                                                                colorScheme),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 3,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                          children: [
                                                            Text(
                                                              '${daily[i].maxTemp.round()}°',
                                                              style: TextStyle(
                                                                fontWeight: FontWeight.w700,
                                                                color: colorScheme.onSurface,
                                                              ),
                                                            ),
                                                            const SizedBox(width: 8),
                                                            Text(
                                                              '${daily[i].minTemp.round()}°',
                                                              style: TextStyle(
                                                                  color: colorScheme
                                                                      .onSurfaceVariant),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (i != daily.length - 1)
                                                  Divider(
                                                      height: 1,
                                                      color: Colors.white.withOpacity(0.2)),
                                              ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (weatherState.isLoading)
                              Container(
                                color: Colors.black.withOpacity(0.15),
                                child: const Center(child: CircularProgressIndicator()),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: 88,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.10),
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.2))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(4, (i) {
                const icons = [
                  Icons.dashboard_rounded,
                  Icons.map_rounded,
                  Icons.calendar_month_rounded,
                  Icons.settings_rounded,
                ];
                final selected = i == _navIndex;
                return GestureDetector(
                  onTap: () => setState(() => _navIndex = i),
                  child: AnimatedScale(
                    scale: selected ? 1.0 : 0.95,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: selected ? colorScheme.primaryContainer : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icons[i],
                        color: selected
                            ? colorScheme.onPrimaryContainer
                            : Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _metricCard({
    required IconData icon,
    required String label,
    required String value,
    required String sub,
    required bool isDark,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return _glassCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Flexible(
                child: Text(label, style: textTheme.labelSmall, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const Spacer(),
          Text(value, style: textTheme.headlineMedium?.copyWith(fontSize: 24)),
          Text(
            sub,
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet with debounced city search, wired to citySearchControllerProvider.
class _CitySearchSheet extends ConsumerStatefulWidget {
  final bool isDark;
  const _CitySearchSheet({required this.isDark});

  @override
  ConsumerState<_CitySearchSheet> createState() => _CitySearchSheetState();
}

class _CitySearchSheetState extends ConsumerState<_CitySearchSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    ref.read(citySearchControllerProvider.notifier).clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(citySearchControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF1C1B19) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colorScheme.outline.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  onChanged: (value) {
                    ref.read(citySearchControllerProvider.notifier).onQueryChanged(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search city…',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _controller.clear();
                        ref.read(citySearchControllerProvider.notifier).clear();
                        setState(() {});
                      },
                    )
                        : null,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (searchState.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (searchState.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      searchState.errorMessage!,
                      style: TextStyle(color: colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  )
                else if (searchState.results.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'Type a city name to search',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: searchState.results.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final city = searchState.results[index];
                          return ListTile(
                            leading: const Icon(Icons.location_city_rounded),
                            title: Text(city.name),
                            subtitle: Text(city.country),
                            onTap: () {
                              ref.read(weatherControllerProvider.notifier).loadWeatherForCity(
                                lat: city.latitude,
                                lon: city.longitude,
                                cityName: '${city.name}, ${city.country}',
                              );
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}