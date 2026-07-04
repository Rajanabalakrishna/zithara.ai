

// presentation/providers/weather_controller.dart
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
  WeatherController(this.ref) : super(const WeatherUiState());

  Future<void> loadCurrentLocationWeather() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final repo = ref.read(weatherRepositoryProvider);
    final result = await repo.getWeatherByCurrentLocation();

    result.fold(
          (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
          (weather) {
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
    state = state.copyWith(isLoading: true, errorMessage: null);
    final repo = ref.read(weatherRepositoryProvider);
    final result = await repo.getWeatherByCoords(
      lat: lat,
      lon: lon,
      cityName: cityName,
    );

    result.fold(
          (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
          (weather) {
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
    if (state.weather == null) return;
    await loadCurrentLocationWeather();
  }
}

final weatherControllerProvider =
StateNotifierProvider<WeatherController, WeatherUiState>((ref) {
  return WeatherController(ref);
});