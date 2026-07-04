// core/location/location_permission_controller.dart
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'location_permission_state.dart';

class LocationPermissionController extends StateNotifier<LocationPermissionUiState> {
  LocationPermissionController() : super(const LocationPermissionUiState()) {
    _listenToServiceStatus();
  }

  StreamSubscription<ServiceStatus>? _serviceStatusSub;

  void _listenToServiceStatus() {
    _serviceStatusSub = Geolocator.getServiceStatusStream().listen((status) async {
      if (status == ServiceStatus.enabled &&
          state.status == LocationPermissionStatus.serviceDisabled) {
        await checkAndRequest();
      }

      if (status == ServiceStatus.disabled &&
          state.status == LocationPermissionStatus.granted) {
        state = state.copyWith(
          status: LocationPermissionStatus.serviceDisabled,
          message: 'Turn on location services to get weather for your area.',
        );
      }
    });
  }

  Future<void> checkAndRequest() async {
    debugPrint('[Permission] checkAndRequest() called');

    state = state.copyWith(
      status: LocationPermissionStatus.checking,
      message: null,
    );

    LocationPermission permission = await Geolocator.checkPermission();
    debugPrint('[Permission] Initial permission: $permission');

    if (permission == LocationPermission.denied) {
      debugPrint('[Permission] Requesting location permission...');
      permission = await Geolocator.requestPermission();
      debugPrint('[Permission] Permission after request: $permission');

      // Android geolocator has edge cases around deniedForever/request dismissal,
      // so checking again is safer in some flows.
      final verifiedPermission = await Geolocator.checkPermission();
      debugPrint('[Permission] Permission after re-check: $verifiedPermission');
      permission = verifiedPermission;
    }

    if (permission == LocationPermission.denied) {
      debugPrint('[Permission] Permission denied');
      state = state.copyWith(
        status: LocationPermissionStatus.permissionDenied,
        message: 'Location permission is required to show weather near you.',
      );
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('[Permission] Permission denied forever');
      state = state.copyWith(
        status: LocationPermissionStatus.permissionDeniedForever,
        message: 'Location permission is permanently denied. Enable it from app settings.',
      );
      return;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    debugPrint('[Permission] Location service enabled: $serviceEnabled');

    if (!serviceEnabled) {
      debugPrint('[Permission] GPS/location service is OFF');
      state = state.copyWith(
        status: LocationPermissionStatus.serviceDisabled,
        message: 'Turn on location services to get weather for your area.',
      );
      return;
    }

    debugPrint('[Permission] Permission granted and GPS ON');
    state = state.copyWith(
      status: LocationPermissionStatus.granted,
      message: null,
    );
  }

  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  @override
  void dispose() {
    _serviceStatusSub?.cancel();
    super.dispose();
  }
}

final locationPermissionControllerProvider = StateNotifierProvider<
    LocationPermissionController, LocationPermissionUiState>((ref) {
  return LocationPermissionController();
});