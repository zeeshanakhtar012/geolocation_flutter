import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_practices/constants/colors.dart';
import 'package:flutter_practices/controllers/controller_register.dart';
import 'package:flutter_practices/controllers/controller_splash.dart';
import 'package:flutter_practices/main.dart';
import 'package:flutter_practices/screens/screenS_sign_up.dart';
import 'package:flutter_practices/screens/screen_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/custom_button.dart';

class ScreensSignUp extends StatelessWidget {
  const ScreensSignUp({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    ControllerRegister controllerRegister = Get.put(ControllerRegister());
    final _formKey = GlobalKey<FormState>();
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        body: Container(
          height: height.sh,
          width: width.sw,
          decoration: BoxDecoration(
            gradient: AppColors.appBackgroundColor,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Once a task is just begun",
                style: GoogleFonts.sofadiOne(
                  textStyle: TextStyle(
                    fontSize: 20.sp,
                    color: Colors.white, letterSpacing: .5,
                  ),
                ),
              ),
              Text(
                "Todo App",
                style: GoogleFonts.fjallaOne(
                  textStyle: TextStyle(
                    fontSize: 20.sp,
                    color: Colors.white, letterSpacing: .5,
                  ),
                ),

              ).marginOnly(
                bottom: 40.h,
              ),

              Form(
                key: _formKey,
                child: Column(
                  children: [
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
                          controller: controllerRegister.email.value,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Email can't be empty";
                            }
                            return null;
                          },
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                            ),
                            hintText: "Email",
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                        vertical: 6.h,
                      ),
                      height: 50.h,
                      width: width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        color: Color(0xFF190733),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextFormField(
                          controller: controllerRegister.password.value,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Password can't be empty";
                            }
                            return null;
                          },
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                          obscureText: true,
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                            ),
                            border: InputBorder.none,
                            hintText: "Password",
                          ),
                        ).marginSymmetric(
                          horizontal: 10.w,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Obx(() {
                return CustomButton(
                  buttonColor: AppColors.buttonColor,
                  isLoading: controllerRegister.isLoading.value,
                  buttonText: 'Sign up',
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      controllerRegister.register();
                    } else {
                      log("Failed to sign up");
                    }
                  },
                );
              }).marginOnly(
                top: 70.w,
              )
            ],
          ).marginSymmetric(
            horizontal: 20.w,
          ),
        ),
      ),
    );
  }
}
