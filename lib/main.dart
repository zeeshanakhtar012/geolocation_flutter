import 'dart:async';
import 'dart:developer';

import 'package:Jazz/controllers/controller_add_data.dart';
import 'package:Jazz/screens/screen_sign_in.dart';
import 'package:Jazz/screens/screen_module.dart'; // Import your ScreenModule
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

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
  ControllerAuthentication controller = Get.put(ControllerAuthentication());

  // Function to check for location permissions
  void _checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      // If permission granted, check login status
      _checkLoginStatus();
    } else {
      // Handle permission denied
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Permission Denied'),
          content: Text('Location permission is required to use this app.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // Function to check login status and handle session timeout
  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    int? loginTime = prefs.getInt('loginTime'); // Get login timestamp

    if (userId != null && userId.isNotEmpty) {
      // If user is logged in, check if 1 hour has passed
      if (loginTime != null && DateTime.now().millisecondsSinceEpoch - loginTime > Duration(hours: 1).inMilliseconds) {
        // Log out after 1 hour
        _logout();
      } else {
        // If still within 1 hour, navigate to ScreenModule
        Get.offAll(ScreenModule());
        // Set a timer to log out after 1 hour
        Timer(Duration(hours: 1), _logout);
      }
    } else {
      // If user is not logged in, navigate to ScreenLogin
      Get.offAll(ScreenLogin());
    }
  }

  // Logout function
  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId'); // Remove user ID
    await prefs.remove('loginTime'); // Remove login timestamp
    Get.offAll(ScreenLogin()); // Navigate to login screen
  }

  @override
  void initState() {
    super.initState();
    _checkPermissions(); // Check permissions when app starts
  }

  late StreamSubscription _sub;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
    enableLights: true,
    enableVibration: true,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('ringtone.mp3'),
    ledColor: const Color.fromARGB(255, 255, 0, 0),
    audioAttributesUsage: AudioAttributesUsage.notificationRingtone,
  );

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
          home: Scaffold(
            body: Center(child: CircularProgressIndicator()), // Show a loading indicator while checking login status
          ),
        );
      },
    );
  }
}
