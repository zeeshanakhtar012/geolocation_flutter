import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../screens/screen_home.dart';
import '../screens/screen_sign_in.dart';

class SplashScreenController extends GetxController {
  Duration splashDuration = const Duration(seconds: 3);

  @override
  void onInit() {
    super.onInit();
    Timer(splashDuration, checkLoginStatus);

  }

  Future<void> checkLoginStatus() async {
    User? user = FirebaseAuth.instance.currentUser;

    await Future.delayed(Duration(milliseconds: 100));

    if (user != null) {
      print("Navigating to ScreenHome");
      Get.offAll(() => ScreenHome());
    } else {
      print("Navigating to ScreenLogin");
      Get.offAll(() => ScreenLogin());
    }
  }
}
