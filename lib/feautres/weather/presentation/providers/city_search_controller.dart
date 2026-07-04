

// presentation/providers/city_search_controller.dart
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/city_entity.dart';
import 'weather_providers.dart';

class CitySearchState {
  final bool isLoading;
  final List<CityEntity> results;
  final String? errorMessage;

  const CitySearchState({
    this.isLoading = false,
    this.results = const [],
    this.errorMessage,
  });

  CitySearchState copyWith({
    bool? isLoading,
    List<CityEntity>? results,
    String? errorMessage,
  }) {
    return CitySearchState(
      isLoading: isLoading ?? this.isLoading,
      results: results ?? this.results,
      errorMessage: errorMessage,
    );
  }
}

class CitySearchController extends StateNotifier<CitySearchState> {
  final Ref ref;
  Timer? _debounce;
  CancelToken? _cancelToken;

  CitySearchController(this.ref) : super(const CitySearchState());

  void onQueryChanged(String query) {
    _debounce?.cancel();
    _cancelToken?.cancel('New query typed');

    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      state = const CitySearchState();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 450), () {
      _search(trimmed);
    });
  }

  Future<void> _search(String query) async {
    _cancelToken = CancelToken();
    state = state.copyWith(isLoading: true, errorMessage: null);

    final repo = ref.read(weatherRepositoryProvider);
    final result = await repo.searchCities(query, cancelToken: _cancelToken);

    result.fold(
          (failure) {
        if (failure.message == 'Request cancelled') return;
        state = state.copyWith(
          isLoading: false,
          results: [],
          errorMessage: failure.message,
        );
      },
          (cities) {
        state = state.copyWith(isLoading: false, results: cities, errorMessage: null);
      },
    );
  }

  void clear() {
    _debounce?.cancel();
    _cancelToken?.cancel();
    state = const CitySearchState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _cancelToken?.cancel();
    super.dispose();
  }
}

final citySearchControllerProvider =
StateNotifierProvider.autoDispose<CitySearchController, CitySearchState>((ref) {
  return CitySearchController(ref);
});