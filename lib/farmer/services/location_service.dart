import 'package:geolocator/geolocator.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;
  final String? errorMessage;
  final bool isSuccess;

  LocationResult({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
    this.errorMessage,
    this.isSuccess = true,
  });

  factory LocationResult.error(String message) {
    return LocationResult(
      latitude: 0.0,
      longitude: 0.0,
      accuracy: 0.0,
      timestamp: DateTime.now(),
      errorMessage: message,
      isSuccess: false,
    );
  }
}

class LocationService {
  /// Validates permissions and captures current GPS fix
  static Future<LocationResult> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Check if GPS hardware service is enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationResult.error('Location services are disabled on this device.');
    }

    // 2. Check permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationResult.error('Location permissions were denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationResult.error('Location permissions are permanently denied in device settings.');
    }

    // 3. Acquire high-accuracy position
    try {
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      return LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        timestamp: position.timestamp,
        isSuccess: true,
      );
    } catch (e) {
      return LocationResult.error('Failed to obtain GPS fix: $e');
    }
  }
}