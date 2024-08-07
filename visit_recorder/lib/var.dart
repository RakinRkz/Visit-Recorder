// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';


String userFullname = '';
String userDesignation = '';
String userSelectedLocation = ''; 

String userLocation = '';
String userCoordinates = '';

Position? userPosition;
Position? userPositionStart;
DateTime userSubmissionStart = DateTime.now();



Future<void> saveUserDataToFile() async {
  // Prepare the data
  var userData = {
    'fullname': userFullname,
    'designation': userDesignation,
    'selectedLocation': userSelectedLocation,
    'location': userLocation,
    'coordinates': userCoordinates,
  };

  // Get the documents directory
  Directory? dir = await getApplicationDocumentsDirectory();
  String filePath = '${dir.path}/user_data.json';

  // Write the file
  File file = File(filePath);
  file.writeAsStringSync(jsonEncode(userData));
}

Future<void> loadUserDataFromFile() async {
  try {
    // Get the documents directory
    Directory? dir = await getApplicationDocumentsDirectory();
    String filePath = '${dir.path}/user_data.json';

    // Check if the file exists
    if (File(filePath).existsSync()) {
      // Read the file
      String jsonData = File(filePath).readAsStringSync();
      // Decode the JSON data
      Map<String, dynamic> userData = jsonDecode(jsonData);

      // Assign the decoded values to the variables
      userFullname = userData['fullname'] ?? '';
      userDesignation = userData['designation'] ?? '';
      userSelectedLocation = userData['selectedLocation'] ?? '';
      userLocation = userData['location'] ?? '';
      userCoordinates = userData['coordinates'] ?? '';
    } else {
      print('No user data found.');
    }
  } catch (e) {
    print('Error loading user data: $e');
  }
}
