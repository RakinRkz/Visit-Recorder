import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:visit_recorder/location_handler.dart';
import 'package:visit_recorder/utils.dart';
import 'package:visit_recorder/var.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  /// OPTIONAL, using custom notification channel id
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    appName, // id
    appName, // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (Platform.isIOS || Platform.isAndroid) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(),
        android: AndroidInitializationSettings('ic_bg_service_small'),
      ),
    );
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: await onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,
      autoStartOnBoot: false,

      notificationChannelId: appName,
      initialNotificationTitle: appName,
      initialNotificationContent: '',
      foregroundServiceNotificationId: 888,
      foregroundServiceType: AndroidForegroundType.location,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );
}

// to ensure this is executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  // For flutter prior to version 3.0.0
  // We have to register the plugin manually

  /// OPTIONAL when use custom notification
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    print('stoping');
    service.stopSelf();
    print('stopped');
  });

  service.on('loc').listen((event) {
    print('lololoc');
  });

  service.on('dataInput').listen((event) {
    userFullname = event!['userFullname'];
    userDesignation = event['userDesignation'];
    userInputLocation = event['userInputLocation'];
    userCoordinates = event['userCoordinates'];
    userGPSLocation = event['userGPSLocation'];
    print('got these data: ');
    print(userFullname);
    print(userDesignation);
  });

  service.on('visitStart').listen((event) async {
    print('started visit invocation');
    await Geolocator.getCurrentPosition(
            locationSettings: LocationSettings(accuracy: LocationAccuracy.low))
        .then((Position position) {
      userPositionStart = position;
      userPosition = position;
      userCoordinates = position.toString();
      print('saved: ' + userCoordinates);
    }).catchError((e) {
      debugPrint(e);
    });

    await placemarkFromCoordinates(
            userPosition.latitude, userPosition.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];

      userGPSLocation =
          '${place.street}, ${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}';
      print(userGPSLocation);
      print(place.toString());
    }).catchError((e) {
      debugPrint(e);
    });

    await send_data();

    Timer.periodic(const Duration(minutes: scanTime), (timer) async {
      await Geolocator.getCurrentPosition(
              locationSettings:
                  LocationSettings(accuracy: LocationAccuracy.low))
          .then((Position position) {
        userPosition = position;
        print(userPosition.toString());
      }).catchError((e) {
        debugPrint(e);
      });

      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          /// OPTIONAL for use custom notification
          /// the notification id must be equals with AndroidConfiguration when you call configure() method.
          flutterLocalNotificationsPlugin.show(
            888,
            appName,
            'will stop automatically...',
            const NotificationDetails(
              android: AndroidNotificationDetails(
                appName,
                appName,
                icon: 'ic_bg_service_small',
                ongoing: true,
              ),
            ),
          );

          // if you don't using custom notification, uncomment this
          // service.setForegroundNotificationInfo(
          //   title: "My App Service",
          //   content: "Updated at ${DateTime.now()}",
          // );
        }
      }

      /// you can see this log in logcat
      print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');

      print(userPositionStart);

      userVisitDuration += scanTime;

      if (calculateDistance(userPositionStart, userPosition) >
          distanceDifference) {
        print(calculateDistance(userPositionStart, userPosition));
        print('visit ended');
        await send_data(duration: userVisitDuration.toString());
        timer.cancel();
        service.stopSelf();
      }
    });
  });
}
