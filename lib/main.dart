import 'dart:async';
import 'dart:developer';

import 'package:Jazz/screens/screen_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {

  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void _checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Request permission if it is not granted
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      // Permission granted, navigate to the next screen
      Get.offAll(ScreenLogin());
    } else {
      // Permission denied, show a message or handle accordingly
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Permission Denied'),
          content: Text('Location permission is required to use this app.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Optionally, exit the app
                // SystemNavigator.pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }
  @override
  void initState() {
    super.initState();
    // checkNotificationPermission();
    _checkPermissions();
  }


  late StreamSubscription _sub;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
    // sound: RawResourceAndroidNotificationSound('notification'),
    enableLights: true,
    enableVibration: true,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('ringtone.mp3'),
    ledColor: const Color.fromARGB(255, 255, 0, 0),
    audioAttributesUsage: AudioAttributesUsage.notificationRingtone,
    // custom ringtone

  );


// Function to check permissions for notifications
//   void checkNotificationPermission() async {
//     var settings = await FirebaseMessaging.instance.requestPermission();
//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       initNotificationChannel();
//     }
//   }

// Initialize notification channel for Android/iOS
  void initNotificationChannel() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
        String? payload = notificationResponse.payload;
        log("Pay $payload");
        // var data=
        // if (payload != null) {
        //   if (data['type'] == 'call') {
        //     log("Now calling");
        //     handleNotificationAction(data);
        //   }
        //   else{
        //     showCallNotification(message.notification!, data);
        //   }
        // }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return GetMaterialApp(
          themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: false,
          title: 'Jazz',
          theme: ThemeData(
            appBarTheme: AppBarTheme(
              centerTitle: true,
              elevation: 0,
              color: Colors.white,
            ),
            primarySwatch: Colors.blue,
            textTheme: Typography.englishLike2018.apply(fontSizeFactor: 1.sp),
          ),
          home: ScreenLogin(),
        );
      },
    );
  }
}
