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
  const ScreenModule({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
              height: 50.h,
              width: 50.w,
              fit: BoxFit.cover,
              "assets/images/jazz.png"),
        ),
          actions: [
            Obx(() {
              final controller = Get.find<ControllerAuthentication>();
              return controller.isLoading.value
                  ? Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: CircularProgressIndicator(
                  color: Colors.red, // Customize the color if needed
                ),
              )
                  : IconButton(
                onPressed: () {
                  controller.logOutUser();
                },
                icon: Icon(Icons.exit_to_app, color: Colors.red),
              );
            }),
          ]
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
      ).marginSymmetric(
        vertical: 15.h,
        horizontal: 15.w,
      ),
    );
  }
  Widget _modules({required String title, required VoidCallback onTap}){
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: 6.h,
        ),
      height: 57.h,
      width: Get.width,
      decoration: BoxDecoration(
      color: Color(0xFF002B5C),
      borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
      child: Text(title, style: TextStyle(
        color: Colors.white,
        fontSize: 16.sp,
        fontWeight: FontWeight.w600
      ),),
      ),
      ),
    );
}
}
