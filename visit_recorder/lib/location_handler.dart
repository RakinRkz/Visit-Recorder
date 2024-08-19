import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:visit_recorder/var.dart';

class LocationHandler {
  var hasPermission = false;

  LocationHandler._privateConstructor();

  // Static instance of the class
  static final LocationHandler _instance =
      LocationHandler._privateConstructor();

  // Public getter to access the instance
  static LocationHandler get instance => _instance;

  Future<void> handleLocationPermission(BuildContext context) async {
    if (hasPermission == true) {
      print('location permission already ok');
      return;
    }
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      hasPermission = false;
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        hasPermission = false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      hasPermission = false;
    }
    hasPermission = true;
  }

  Future<void> _getCurrentPosition() async {
    await Geolocator.getCurrentPosition(
            locationSettings: LocationSettings(accuracy: LocationAccuracy.lowest))
        .then((Position position) {
      userPosition = position;
      userCoordinates = position.toString();
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _getAddressFromLatLng() async {
    await placemarkFromCoordinates(
            userPosition.latitude, userPosition.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];

      userLocation =
          '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> updateLocation() async {
    if (!hasPermission) return;
    await _getCurrentPosition();
    await _getAddressFromLatLng();
    saveUserDataToFile();
  }

  Future<void> saveLocation() async {
    await updateLocation();
    userPositionStart = userPosition;
  }
}

double calculateDistance(Position pos1, Position pos2) {
  print(pos1);
  print('pos1 mock?');
  print(pos1.isMocked);
  print(pos2);
  print('pos2 mock?');
  print(pos2.isMocked);

  double lat1 = pos1.latitude;
  double lon1 = pos1.longitude;

  double lat2 = pos2.latitude;
  double lon2 = pos2.longitude;

  const R = 6371; // Radius of the earth in kilometers

  final a = sin(deg2rad(lat1)) * sin(deg2rad(lat2)) +
      cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * cos(deg2rad(lon2 - lon1));
  final c = acos(a);
  final d = R * c * 1000; // in meters

  return d;
}

// Helper function to convert degrees to radians
double deg2rad(double deg) {
  return deg * (pi / 180);
}
