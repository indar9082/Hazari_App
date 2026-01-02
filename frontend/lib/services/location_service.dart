// lib/services/location_service.dart
import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<String> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return "${position.latitude},${position.longitude}";
    } catch (e) {
      print('Location error: $e');
      return "28.6139,77.2090"; // Delhi fallback
    }
  }
}
