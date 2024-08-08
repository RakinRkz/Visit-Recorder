import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:visit_recorder/location_handler.dart';
import 'package:visit_recorder/var.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _currentAddress;
  Position? _currentPosition;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: (const Row(
        children: [Icon(Icons.account_box), Text("User Details")],
      ))),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(
                Icons.person,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  const Text('Full Name:  '),
                  // Text(user_fullname),
                  Container(
                    width: 250,
                    margin: const EdgeInsets.only(right: 8.0),
                    child: TextField(
                      // controller: idController,
                      controller: TextEditingController(text: userFullname),
                      onChanged: (value) {
                        userFullname = value;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Enter full name !!',
                        hintStyle: TextStyle(color: Colors.red),
                      ),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  const Text('Designation: '),
                  Container(
                    width: 250,
                    margin: const EdgeInsets.only(right: 8.0),
                    child: TextField(
                      // controller: idController,
                      controller: TextEditingController(text: userDesignation),
                      onChanged: (value) {
                        userDesignation = value;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Enter your designation !!',
                        hintStyle: TextStyle(color: Colors.red),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  print(userFullname);
                  print(userDesignation);
                  saveUserDataToFile();
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
              const SizedBox(height: 32),
              const Icon(Icons.pin_drop),
              Text('LAT: ${_currentPosition?.latitude ?? ""}'),
              Text('LNG: ${_currentPosition?.longitude ?? ""}'),
              Text('ADDRESS: ${_currentAddress ?? ""}'),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  LocationHandler.instance.handleLocationPermission(context);
                  LocationHandler.instance.updateLocation();
                  sleep(Duration(seconds: 3));
                  saveUserDataToFile();

                  setState(() {
                    _currentPosition = userPosition;
                    _currentAddress = userLocation;
                  });
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on),
                    Text('Refresh Location'),
                    Icon(Icons.refresh),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
