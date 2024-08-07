import 'package:gsheets/gsheets.dart';
import 'package:visit_recorder/creds.dart';


/// Your spreadsheet id
///
/// It can be found in the link to your spreadsheet -
/// link looks like so https://docs.google.com/spreadsheets/d/YOUR_SPREADSHEET_ID/edit#gid=0
/// [YOUR_SPREADSHEET_ID] in the path is the id your need
const _spreadsheetId = '1QndPsrFf6o2X9LYCbtAz668kaeayEyymTjCoD_f5HdU';

const workSheet = 'records';

void send_data(
    String submittedLocation, String gpsCoordinates, String gpsLocation, {String duration='0'} ) async {
  var _credentials = creds;
  final gsheet = GSheets(_credentials);
  final ss = await gsheet.spreadsheet(_spreadsheetId);

  var sheet = ss.worksheetByTitle(workSheet);
  sheet ??= await ss.addWorksheet(workSheet);

  final _record = {
    'timestamp': DateTime.now().toString(),
    'Name': 'user_fullname',
    'Designation': 'user_designation',
    'Submitted Location': submittedLocation,
    'GPS Coordinates': gpsCoordinates,
    'GPS Location': gpsLocation,
    'duration': duration,
  };
  await sheet.values.map.appendRow(_record);
  // prints {index: 5, letter: f, number: 6, label: f6}
  print(await sheet.values.map.lastRow());
}



// void main() async {
//   // send_data();
//   print(DateTime.now().toString());
//   // String jsonString = await rootBundle.loadString('assets/credentials.json');
//   // print(jsonString);
  

// }
