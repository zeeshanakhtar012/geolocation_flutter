import 'package:Jazz/controllers/controller_add_data.dart';
import 'package:Jazz/screens/screen_module.dart';
import 'package:Jazz/screens/screen_otp.dart';
import 'package:Jazz/screens/screen_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/colors.dart';
import '../widgets/custom_button.dart';

class ScreenAddNumberWhiteList extends StatelessWidget {
  const ScreenAddNumberWhiteList({super.key});

  @override
  Widget build(BuildContext context) {
    ControllerAuthentication controllerLocation =  Get.put(ControllerAuthentication());
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(15.r),
              child: Image.asset("assets/images/jazz.png")),
          Text(
            "Jazz",
            style: GoogleFonts.sofadiOne(
              textStyle: TextStyle(
                fontSize: 35.sp,
                color: Colors.black,
                letterSpacing: .5,
              ),
            ),
          ).marginOnly(
            bottom: 10.h,
          ),
          Text(
            textAlign: TextAlign.center,
            "Whitelisted Numbers",
            style: GoogleFonts.aBeeZee(
              textStyle: TextStyle(
                fontSize: 20.sp,
                color: Colors.black,
                letterSpacing: .5,
              ),
            ),
          ).marginOnly(
            bottom: 10.h,
          ),
          Container(
            padding: EdgeInsets.only(left: 10.w),
            height: 50.h,
            width: width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: Color(0xFF190733),
            ),
            child: Center(
              child: TextFormField(
                controller: controllerLocation.phoneNo.value,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                  hintText: "+92 300 1234567",
                ),
              ),
            ),
          ).marginOnly(
            bottom: 10.h,
          ),
          CustomButton(
            buttonColor: AppColors.buttonColor,
            buttonText: 'Login',
            onTap: () async{
              await controllerLocation.saveData();
              Get.to(ScreenLogin());
            },
          ).marginOnly(
            top: 10.w,
          ),
        ],
      ).marginSymmetric(
        horizontal: 20.w,
      ),
    );
  }
}
