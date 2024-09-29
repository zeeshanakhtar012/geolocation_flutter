//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get/get.dart';
//
// import '../../screen_agora_audio_call.dart';
//
// class NotificationService {
//   final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//   void initializeNotifications() {
//     final initializationSettings = InitializationSettings(
//       android: AndroidInitializationSettings('@mipmap/ic_launcher'),
//       iOS: IOSInitializationSettings(),
//     );
//     _flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onSelectNotification: _onSelectNotification,
//     );
//   }
//
//   Future<void> _onSelectNotification(String? payload) async {
//     if (payload != null) {
//       final Map<String, dynamic> data = json.decode(payload);
//       final channelId = data['channelId'];
//       Get.to(AgoraAudioCall(channelId: channelId));
//     }
//   }
//
//   Future<void> showNotification(String channelId) async {
//     const androidPlatformChannelSpecifics = AndroidNotificationDetails(
//       'call_channel_id',
//       'Call Notifications',
//       importance: Importance.max,
//       priority: Priority.high,
//     );
//     const iOSPlatformChannelSpecifics = IOSNotificationDetails();
//     const platformChannelSpecifics = NotificationDetails(
//       android: androidPlatformChannelSpecifics,
//       iOS: iOSPlatformChannelSpecifics,
//     );
//
//     await _flutterLocalNotificationsPlugin.show(
//       0,
//       'Incoming Call',
//       'You have an incoming call. Click to join.',
//       platformChannelSpecifics,
//       payload: json.encode({'channelId': channelId}),
//     );
//   }
// }
