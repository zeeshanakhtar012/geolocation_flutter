import 'package:flutter/material.dart';
import 'package:flutter_practices/controllers/controller_splash.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class ScreenSplash extends StatefulWidget {
  const ScreenSplash({super.key});

  @override
  State<ScreenSplash> createState() => _ScreenSplashState();
}

class _ScreenSplashState extends State<ScreenSplash> {
  @override
  void initState() {
    super.initState();
    SplashScreenController controller = Get.put(SplashScreenController());
    controller.checkLoginStatus();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.green,
        child: Center(
          child: Text("Splash screen!!"),
        ),
      ),
    );
  }
}
