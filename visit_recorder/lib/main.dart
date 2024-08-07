import 'dart:io';

import 'package:flutter/material.dart';
import 'package:visit_recorder/location_handler.dart';
import 'package:visit_recorder/profile_page.dart';
import 'package:visit_recorder/test.dart';
import 'package:visit_recorder/var.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Visit Recorder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Visit Recorder'),
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
  bool preSubmissionChecksPassed() {
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

    LocationHandler.instance.handleLocationPermission(context);
    sleep(const Duration(seconds: 2));

    return true;
  }

  void onSubmitPressed() {
    if (preSubmissionChecksPassed()) {
      print(userSelectedLocation);
      LocationHandler.instance.saveLocation();
      send_data('user_location', 'user_coordinates', 'user_location');

      setState(() {});
    }
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
            onPressed: () {
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
              controller: TextEditingController(text: userSelectedLocation),
              onChanged: (value) {
                userSelectedLocation = value;
              },
              decoration: const InputDecoration(
                hintText: 'Enter place of visit here !!',
                hintStyle: TextStyle(color: Colors.red),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: (onSubmitPressed),
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
