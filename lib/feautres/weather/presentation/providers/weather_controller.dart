// presentation/providers/weather_controller.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/weather_entity.dart';
import 'weather_providers.dart';

class WeatherUiState {
  final bool isLoading;
  final WeatherEntity? weather;
  final String? errorMessage;
  final bool showingOfflineData;

  const WeatherUiState({
    this.isLoading = false,
    this.weather,
    this.errorMessage,
    this.showingOfflineData = false,
  });

  WeatherUiState copyWith({
    bool? isLoading,
    WeatherEntity? weather,
    String? errorMessage,
    bool? showingOfflineData,
  }) {
    return WeatherUiState(
      isLoading: isLoading ?? this.isLoading,
      weather: weather ?? this.weather,
      errorMessage: errorMessage,
      showingOfflineData: showingOfflineData ?? this.showingOfflineData,
    );
  }
}

class WeatherController extends StateNotifier<WeatherUiState> {
  final Ref ref;

  // ✅ BUG 3 FIX: Constructor now immediately loads Hive cache so UI
  // shows cached data (not 0°) while the live fetch is in progress.
  WeatherController(this.ref) : super(const WeatherUiState()) {
    debugPrint('[WeatherController] Created — loading Hive cache immediately...');
    _loadCacheImmediately();
  }

  /// Loads cached weather from Hive at startup.
  /// This runs BEFORE loadCurrentLocationWeather() so the UI always has
  /// something to show instead of displaying all-zero values.
  Future<void> _loadCacheImmediately() async {
    final repo = ref.read(weatherRepositoryProvider);
    final cached = await repo.getCachedWeatherOrFail();

    cached.fold(
          (failure) {
        // No cache yet (e.g., fresh install) — this is expected.
        debugPrint('[WeatherController] No Hive cache on startup: ${failure.message}');
      },
          (weather) {
        debugPrint(
          '[WeatherController] ✅ Hive cache loaded — '
              'city: ${weather.cityName}, temp: ${weather.currentTemp}°, '
              'fetchedAt: ${weather.fetchedAt}',
        );
        state = state.copyWith(
          weather: weather,
          showingOfflineData: true, // Mark as stale until fresh fetch completes
        );
      },
    );
  }

  Future<void> loadCurrentLocationWeather() async {
    debugPrint('[WeatherController] loadCurrentLocationWeather() called');
    state = state.copyWith(isLoading: true, errorMessage: null);

    final repo = ref.read(weatherRepositoryProvider);
    final result = await repo.getWeatherByCurrentLocation();

    result.fold(
          (failure) {
        debugPrint('[WeatherController] ❌ Location weather failed: ${failure.message}');
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
          (weather) {
        debugPrint(
          '[WeatherController] ✅ Location weather fetched — '
              'city: ${weather.cityName}, temp: ${weather.currentTemp}°, '
              'isFromCache: ${weather.isFromCache}',
        );
        state = state.copyWith(
          isLoading: false,
          weather: weather,
          showingOfflineData: weather.isFromCache,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> loadWeatherForCity({
    required double lat,
    required double lon,
    required String cityName,
  }) async {
    debugPrint('[WeatherController] loadWeatherForCity() → $cityName ($lat, $lon)');
    state = state.copyWith(isLoading: true, errorMessage: null);

    final repo = ref.read(weatherRepositoryProvider);
    final result = await repo.getWeatherByCoords(
      lat: lat,
      lon: lon,
      cityName: cityName,
    );

    result.fold(
          (failure) {
        debugPrint('[WeatherController] ❌ City weather failed: ${failure.message}');
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
          (weather) {
        debugPrint(
          '[WeatherController] ✅ City weather fetched — '
              'city: ${weather.cityName}, temp: ${weather.currentTemp}°, '
              'isFromCache: ${weather.isFromCache}',
        );
        state = state.copyWith(
          isLoading: false,
          weather: weather,
          showingOfflineData: weather.isFromCache,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> refresh() async {
    debugPrint('[WeatherController] refresh() called, weather is null: ${state.weather == null}');
    if (state.weather == null) return;
    await loadCurrentLocationWeather();
  }
}

final weatherControllerProvider =
StateNotifierProvider<WeatherController, WeatherUiState>((ref) {
  return WeatherController(ref);
});