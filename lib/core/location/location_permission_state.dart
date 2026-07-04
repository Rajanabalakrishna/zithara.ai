

// core/location/location_permission_state.dart
enum LocationPermissionStatus {
  initial,
  checking,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  granted,
}

class LocationPermissionUiState {
  final LocationPermissionStatus status;
  final String? message;

  const LocationPermissionUiState({
    this.status = LocationPermissionStatus.initial,
    this.message,
  });

  LocationPermissionUiState copyWith({
    LocationPermissionStatus? status,
    String? message,
  }) {
    return LocationPermissionUiState(
      status: status ?? this.status,
      message: message,
    );
  }
}