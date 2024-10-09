import 'package:Jazz/screens/screen_live_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

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
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _modules(title: 'Jazz Trade Intelligence', onTap: () {
            Get.to(ScreenAddInformation(isIntelligence: true,));
          }),
          _modules(title: 'Visit Log', onTap: () {
            Get.to(ScreenAddInformation(isVisit: true,));
          }),
          _modules(title: 'Asset Deployment', onTap: () {
            Get.to(ScreenAddInformation(isAssetDeploy: true,));
          }),
          _modules(title: 'Trade Asset', onTap: () {
            Get.to(ScreenAddInformation(isTradeAssets: true,));
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
