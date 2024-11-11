import 'package:Jazz/controllers/controller_add_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';
import '../widgets/custom_button.dart';

class ScreenLogin extends StatelessWidget {
  const ScreenLogin({super.key});

  @override
  Widget build(BuildContext context) {
    // Instantiate the ControllerAuthentication
    ControllerAuthentication controllerAuthentication = Get.put(ControllerAuthentication());
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"), // You can customize this as needed
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15.r),
              child: Image.asset("assets/images/jazz.png"),
            ),
            Text(
              "Jazz",
              style: GoogleFonts.sofadiOne(
                textStyle: TextStyle(
                  fontSize: 35.sp,
                  color: Colors.black,
                  letterSpacing: .5,
                ),
              ),
            ).marginOnly(bottom: 10.h),
            Text(
              textAlign: TextAlign.center,
              "Meri Superpower",
              style: GoogleFonts.aBeeZee(
                textStyle: TextStyle(
                  fontSize: 20.sp,
                  color: Colors.black,
                  letterSpacing: .5,
                ),
              ),
            ).marginOnly(bottom: 10.h),
            Container(
              padding: EdgeInsets.only(left: 10.w),
              height: 50.h,
              width: width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: Color(0xFF190733),
              ),
              child: Center(
                child: Obx(() {
                  return TextFormField(
                    controller: controllerAuthentication.phoneNo.value,
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
                  );
                }),
              ),
            ).marginOnly(bottom: 10.h),
            Container(
              padding: EdgeInsets.only(left: 10.w),
              height: 50.h,
              width: width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: Color(0xFF190733),
              ),
              child: Center(
                child: Obx(() {
                  return TextFormField(
                    controller: controllerAuthentication.password.value,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                    keyboardType: TextInputType.text, // Change to text for FID
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                      hintText: "Enter password",
                    ),
                  );
                }),
              ),
            ).marginOnly(bottom: 10.h, top: 10.h),
            Obx(() {
              return CustomButton(
                isLoading: controllerAuthentication.isLoading.value,
                buttonColor: AppColors.buttonColor,
                buttonText: 'Login',
                onTap: () async {
                  await controllerAuthentication.verifyPhoneNumber();
                }
                );
            }).marginOnly(top: 10.w),
          ],
        ).marginSymmetric(horizontal: 20.w),
      ),
    );
  }
}
