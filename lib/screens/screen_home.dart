import 'package:flutter/material.dart';
import 'package:flutter_practices/controllers/controller_register.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class ScreenHome extends StatelessWidget {
  const ScreenHome({super.key});

  @override
  Widget build(BuildContext context) {
    ControllerRegister controllerRegister = Get.put(ControllerRegister());
    controllerRegister.logout();
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                controllerRegister.logout();
              },
              icon: Icon(Icons.logout))
        ],
        title: Text("Screen HomePage"),
      ),
      body: Stack(alignment: Alignment.center, children: [
        Column(
          children: [
            Text("HomePage Screen"),
          ],
        ),
        Obx(() {
          return controllerRegister.isLoading.value
              ? Container(
                  color: Colors.black.withOpacity(.3),
                  child: Center(
                    child: CircularProgressIndicator.adaptive(
                      backgroundColor: Colors.red,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 5,
                    ),
                  ),
                )
              : SizedBox.shrink();
        })
      ]),
    );
  }
}
