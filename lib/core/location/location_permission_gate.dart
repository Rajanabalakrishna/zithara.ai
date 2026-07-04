// core/location/location_permission_gate.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'location_permission_controller.dart';
import 'location_permission_state.dart';

class LocationPermissionGate extends ConsumerStatefulWidget {
  final Widget child;
  const LocationPermissionGate({super.key, required this.child});

  @override
  ConsumerState<LocationPermissionGate> createState() => _LocationPermissionGateState();
}

class _LocationPermissionGateState extends ConsumerState<LocationPermissionGate> {
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationPermissionControllerProvider.notifier).checkAndRequest();
    });
  }

  void _maybeShowDialog(LocationPermissionUiState state) {
    if (_dialogShown) return;

    if (state.status == LocationPermissionStatus.serviceDisabled) {
      _dialogShown = true;
      _showServiceDisabledDialog();
    } else if (state.status == LocationPermissionStatus.permissionDenied) {
      _dialogShown = true;
      _showPermissionDeniedDialog();
    } else if (state.status == LocationPermissionStatus.permissionDeniedForever) {
      _dialogShown = true;
      _showGoToSettingsDialog();
    }
  }

  void _closeDialogIfOpen(LocationPermissionUiState state) {
    if (_dialogShown && state.status == LocationPermissionStatus.granted && mounted) {
      Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
      _dialogShown = false;
    }
  }

  void _showServiceDisabledDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Turn on location'),
          content: const Text(
            'Location permission is allowed, but GPS/location service is off. Please turn it on to continue.',
          ),
          actions: [
            FilledButton(
              onPressed: () async {
                await ref.read(locationPermissionControllerProvider.notifier).openLocationSettings();
              },
              child: const Text('Open Location Settings'),
            ),
          ],
        );
      },
    ).then((_) {
      _dialogShown = false;
    });
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Permission required'),
          content: const Text(
            'Location permission is needed. Please allow it to fetch weather for your current location.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _dialogShown = false;
              },
              child: const Text('Not now'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(context).pop();
                _dialogShown = false;
                await ref.read(locationPermissionControllerProvider.notifier).checkAndRequest();
              },
              child: const Text('Allow Again'),
            ),
          ],
        );
      },
    ).then((_) {
      _dialogShown = false;
    });
  }

  void _showGoToSettingsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enable permission in settings'),
          content: const Text(
            'Location permission was denied permanently. Go to app settings and enable location permission.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _dialogShown = false;
              },
              child: const Text('Not now'),
            ),
            FilledButton(
              onPressed: () async {
                await ref.read(locationPermissionControllerProvider.notifier).openAppSettings();
              },
              child: const Text('Go to Settings'),
            ),
          ],
        );
      },
    ).then((_) {
      _dialogShown = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(locationPermissionControllerProvider);

    ref.listen<LocationPermissionUiState>(
      locationPermissionControllerProvider,
          (previous, next) {
        _closeDialogIfOpen(next);
        _maybeShowDialog(next);
      },
    );

    if (state.status == LocationPermissionStatus.checking ||
        state.status == LocationPermissionStatus.initial) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.status == LocationPermissionStatus.permissionDenied ||
        state.status == LocationPermissionStatus.permissionDeniedForever) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off_rounded, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Location permission is required to use this screen.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Go to app settings, turn on location permission, and come back.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () async {
                      await ref
                          .read(locationPermissionControllerProvider.notifier)
                          .openAppSettings();
                    },
                    child: const Text('Go to App Settings'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () async {
                      await ref
                          .read(locationPermissionControllerProvider.notifier)
                          .checkAndRequest();
                    },
                    child: const Text('Check Again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (state.status == LocationPermissionStatus.serviceDisabled) {
      return widget.child;
    }

    return widget.child;
  }
}