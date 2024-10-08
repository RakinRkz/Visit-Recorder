import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:visit_recorder/location_handler.dart';
import 'package:visit_recorder/profile_page.dart';
import 'package:visit_recorder/service_handler.dart';
import 'package:visit_recorder/utils.dart';
import 'package:visit_recorder/var.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  // await loadUserDataFromFile();
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: appName),
      // home: ProfilePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String userInputLocation_ = '';
  Future<bool> preSubmissionChecksPassed() async {
    await LocationHandler.instance.handleLocationPermission(context);

    if (userFullname == '' || userDesignation == '') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfilePage(),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please fill up your Name and Designation first')));
      return false;
    }
    
    print(userInputLocation);

    if (userInputLocation == '') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please fill up your place of visit !')));
      return false;
    }

    return true;
  }

  Future<void> onSubmitPressed() async {
    userInputLocation = userInputLocation_;

    bool res = await preSubmissionChecksPassed();
    if (res) {
      final service = FlutterBackgroundService();
      service.invoke(
        'dataInput',
        {
          "userFullname": userFullname,
          "userDesignation": userDesignation,
          "userInputLocation": userInputLocation,
          "userCoordinates": userCoordinates,
          "userGPSLocation": userGPSLocation,
        },
      );

      service.invoke('visitStart');

      setState(() {
        userInputLocation_ = '';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserDataFromFile();
    requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'User Details',
            onPressed: () async {
              // await LocationHandler.instance.handleLocationPermission(context);
              // await LocationHandler.instance.updateLocation();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfilePage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Write visiting place: ',
            ),
            TextField(
              // controller: idController,
              controller: TextEditingController(text: userInputLocation_),
              onChanged: (value) {
                userInputLocation_ = value;
              },
              onTapOutside: (event) {
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus &&
                    currentFocus.focusedChild != null) {
                  FocusManager.instance.primaryFocus?.unfocus();
                }
              },
              decoration: const InputDecoration(
                hintText: 'Write place of visit here !!',
                hintStyle: TextStyle(color: Colors.red),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await onSubmitPressed();
            _dialogBuilder(context);
          },
          tooltip: 'Save record',
          child: const Column(
            children: [
              Icon(Icons.send_rounded),
              Text('Submit'),
            ],
          )),
    );
  }
}

void requestPermission() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.location,
    Permission.notification,
  ].request();

  statuses.values.forEach((element) async {
    if (element.isDenied || element.isPermanentlyDenied) {
      await openAppSettings();
    }
  });
}

Future<void> _dialogBuilder(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Submission Done'),
        content: const Text('Press Ok to exit the app'),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop();
              SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            },
          ),
        ],
      );
    },
  );
}
