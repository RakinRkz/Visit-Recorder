import 'package:flutter/material.dart';
import 'package:visit_recorder/location_handler.dart';
import 'package:visit_recorder/profile_page.dart';
import 'package:visit_recorder/utils.dart';
import 'package:visit_recorder/var.dart';

void main() async {
  // await loadUserDataFromFile();
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
    bool res = await preSubmissionChecksPassed();
    if (res) {
      await LocationHandler.instance.saveLocation();
      userSubmissionStart = DateTime.now();

      invokeService();

      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserDataFromFile();

    LocationHandler.instance.handleLocationPermission(context);
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
              await LocationHandler.instance.handleLocationPermission(context);
              await LocationHandler.instance.updateLocation();
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
              controller: TextEditingController(text: ''),
              onChanged: (value) {
                userInputLocation = value;
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
