// core/location/location_permission_controller.dart
import 'dart:async';
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
    state = state.copyWith(
      status: LocationPermissionStatus.checking,
      message: null,
    );

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      state = state.copyWith(
        status: LocationPermissionStatus.permissionDenied,
        message: 'Location permission is required to show weather near you.',
      );
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      state = state.copyWith(
        status: LocationPermissionStatus.permissionDeniedForever,
        message: 'Location permission is permanently denied. Enable it from app settings.',
      );
      return;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      state = state.copyWith(
        status: LocationPermissionStatus.serviceDisabled,
        message: 'Turn on location services to get weather for your area.',
      );
      return;
    }

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