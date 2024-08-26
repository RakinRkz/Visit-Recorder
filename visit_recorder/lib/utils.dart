import 'package:gsheets/gsheets.dart';
import 'package:visit_recorder/creds.dart';
import 'package:visit_recorder/var.dart';

/// Your spreadsheet id
///
/// It can be found in the link to your spreadsheet -
/// link looks like so https://docs.google.com/spreadsheets/d/YOUR_SPREADSHEET_ID/edit#gid=0
/// [YOUR_SPREADSHEET_ID] in the path is the id your need
const _spreadsheetId = '1QndPsrFf6o2X9LYCbtAz668kaeayEyymTjCoD_f5HdU';

const workSheet = 'records';

Future<void> send_data({String duration = 'start'}) async {
  var _credentials = creds;
  final gsheet = GSheets(_credentials);
  final ss = await gsheet.spreadsheet(_spreadsheetId);

  var sheet = ss.worksheetByTitle(workSheet);
  sheet ??= await ss.addWorksheet(workSheet);

  final _record = {
    'timestamp': userPosition.timestamp.toString(),
    'Name': userFullname,
    'Designation': userDesignation,
    'Submitted Location': userInputLocation,
    'GPS Coordinates': userCoordinates,
    'GPS Location': userGPSLocation,
    'duration': duration+' minute(s)',
  };
  await sheet.values.map.appendRow(_record);
  // prints {index: 5, letter: f, number: 6, label: f6}
  print(await sheet.values.map.lastRow());
}