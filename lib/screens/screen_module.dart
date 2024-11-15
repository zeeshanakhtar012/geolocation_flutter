import 'dart:developer';

import 'package:Jazz/screens/screen_live_location.dart';
import 'package:Jazz/screens/screen_market_visit_log.dart';
import 'package:Jazz/screens/screen_module_intelligence.dart';
import 'package:Jazz/screens/screen_new_asset_deployment.dart';
import 'package:Jazz/screens/screen_new_trade_asset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/controller_add_data.dart';

class ScreenModule extends StatelessWidget {
  ScreenModule({super.key});
  ControllerAuthentication controller = Get.put(ControllerAuthentication());

  @override
  Widget build(BuildContext context) {
    controller.fetchUserDetails();
    log("User Name is ${controller.user.value?.userName}");
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Row(
          children: [
            Icon(Icons.person, color: Colors.green,),
            SizedBox(
              width: 2.w,
            ),
            Obx(() {
              final user = controller.user.value;
              print("User name = ${user?.userName}");
              if (user == null) {
                return Text("Loading...", style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),);
              }
              return Text("${user.userName}", style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
              ),);
            }),
          ],
        ),
        // actions: [
        //   Obx(() {
        //     final minutes = ((controller.timeRemaining.value % 3600) ~/ 60)
        //         .toString()
        //         .padLeft(2, '0');
        //     final seconds = (controller.timeRemaining.value % 60)
        //         .toString()
        //         .padLeft(2, '0');
        //     return Text(
        //       '$minutes:$seconds',
        //       style: TextStyle(color: Colors.red),
        //     );
        //   }),
        //   SizedBox(width: 10),
        // ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _modules(title: 'Market Intelligence', onTap: () {
            Get.to(ScreenModuleIntelligence());
          }),
          _modules(title: 'Market Visit Log', onTap: () {
            Get.to(ScreenMarketVisitLog());
          }),
          _modules(title: 'New Asset Deployment', onTap: () {
            Get.to(ScreenNewAssetDeployment());
          }),
          _modules(title: 'New Trade Asset Requirements', onTap: () {
            Get.to(ScreenNewTradeAsset());
          }),
        ],
      ).marginSymmetric(vertical: 15.h, horizontal: 15.w),
    );
  }

  Widget _modules({required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6.h),
        height: 57.h,
        width: Get.width,
        decoration: BoxDecoration(
          color: Color(0xFF002B5C),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}