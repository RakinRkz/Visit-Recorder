// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';


String userFullname = '';
String userDesignation = '';
String userInputLocation = ''; 

String userLocation = '';
String userCoordinates = '';

late Position userPosition;
late Position userPositionStart;
DateTime userSubmissionStart = DateTime.now();

const int scanTime = 1;
const double distanceDifference = 100.00;

int userVisitDuration = 0;
// ______________________________________

Future<void> saveUserDataToFile() async {
  // Prepare the data
  var userData = {
    'fullname': userFullname,
    'designation': userDesignation,
    'location': userLocation,
    'coordinates': userCoordinates,
  };

  // Get the documents directory
  Directory? dir = await getApplicationDocumentsDirectory();
  String filePath = '${dir.path}/user_data.json';

  // Write the file
  File file = File(filePath);
  file.writeAsStringSync(jsonEncode(userData));
  print('saved data');
}

Future<void> loadUserDataFromFile() async {
  print('Reading User data');

  try {
    // Get the documents directory
    Directory? dir = await getApplicationDocumentsDirectory();
    String filePath = '${dir.path}/user_data.json';

    // Check if the file exists
    if (File(filePath).existsSync()) {
      print('Reading User data');
      // Read the file
      String jsonData = File(filePath).readAsStringSync();
      // Decode the JSON data
      Map<String, dynamic> userData = jsonDecode(jsonData);

      // Assign the decoded values to the variables
      userFullname = userData['fullname'] ?? '';
      userDesignation = userData['designation'] ?? '';
      userLocation = userData['location'] ?? '';
      userCoordinates = userData['coordinates'] ?? '';
    } else {
      print('No user data found.');
    }
  } catch (e) {
    print('Error loading user data: $e');
  }
}
