// import 'package:Jazz/constants/colors.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:pinput/pinput.dart';
// import 'dart:async';
// import '../../widgets/my_input_feild.dart';
// import '../widgets/custom_button.dart';
//
// class ScreenVerifyOtp extends StatefulWidget {
//   // String email;
//
//   @override
//   _ScreenVerifyOtpState createState() => _ScreenVerifyOtpState();
//
//     ScreenVerifyOtp({
//       super.key,
//       // required this.email,
//     });
//
// }
//
// class _ScreenVerifyOtpState extends State<ScreenVerifyOtp> {
//   final defaultPinTheme = PinTheme(
//     width: 58.w,
//     height: 58.h,
//     textStyle: TextStyle(
//       fontSize: 20,
//       color: Color.fromRGBO(30, 60, 87, 1),
//       fontWeight: FontWeight.w600,
//     ),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.1),
//           blurRadius: 5.r,
//           offset: Offset(0, 5),
//         ),
//       ],
//       borderRadius: BorderRadius.circular(10.r),
//     ),
//   );
//
//   Timer? _timer;
//   int _start = 60;
//
//   void startTimer() {
//     _start = 60;
//     const oneSec = const Duration(seconds: 1);
//     _timer = new Timer.periodic(
//       oneSec,
//           (Timer timer) {
//         if (_start == 0) {
//           setState(() {
//             timer.cancel();
//           });
//         } else {
//           setState(() {
//             _start--;
//           });
//         }
//       },
//     );
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     startTimer();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final focusedPinTheme = defaultPinTheme.copyWith(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 5.r,
//             offset: Offset(0, 5),
//           ),
//         ],
//         borderRadius: BorderRadius.circular(10.r),
//       ),
//     );
//
//     final submittedPinTheme = defaultPinTheme.copyWith(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 5.r,
//             offset: Offset(0, 5),
//           ),
//         ],
//         borderRadius: BorderRadius.circular(10.r),
//       ),
//     );
//
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       appBar: AppBar(
//         title: Text("Verify Otp", style: TextStyle(
//           fontSize: 16.sp,
//           fontWeight: FontWeight.w600,
//           color: Colors.green,
//         ),),
//           elevation: 0,
//           centerTitle: true,
//           backgroundColor: Colors.white,
//           leading: IconButton(onPressed: (){}, icon: Icon(Icons.arrow_back, color: Colors.green,))
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: <Widget>[
//           SizedBox(height: 20.h),
//           Text(
//             "Verify OTP",
//             style: TextStyle(
//               fontSize: 30.sp,
//               fontWeight: FontWeight.w700,
//               color: Colors.black,
//             ),
//           ),
//           SizedBox(height: 20.h),
//           Text(
//             "Enter your OTP which has been sent to your phone Number and complete verify your account",
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: Color(0xFF838383),
//               fontSize: 14.sp,
//               fontWeight: FontWeight.w400,
//             ),
//           ),
//           SizedBox(height: 20.h),
//           Pinput(
//             // controller: authController.otpController,
//             defaultPinTheme: defaultPinTheme,
//             focusedPinTheme: focusedPinTheme,
//             submittedPinTheme: submittedPinTheme,
//
//
//             pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
//             showCursor: true,
//             onCompleted: (pin) => print(pin),
//           ),
//           SizedBox(height: 20.h),
//           Text(
//             "A code has been sent to your phone",
//             style: TextStyle(
//               color: Color(0xFF717171),
//               fontSize: 14.sp,
//               fontWeight: FontWeight.w400,
//             ),
//           ),
//           SizedBox(height: 10.h),
//           _start == 0
//               ? GestureDetector(
//             onTap: () {
//               // Resend OTP logic
//               startTimer();
//             },
//             child: Text(
//               "Resend Code",
//               style: TextStyle(
//                 color: Colors.green,
//                 fontSize: 14.sp,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           )
//               : Text(
//             "Resend in 00:${_start.toString().padLeft(2, '0')}",
//             style: TextStyle(
//               color: Colors.red,
//               fontSize: 14.sp,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//           Spacer(),
//           CustomButton(
//             buttonColor: AppColors.buttonColor,
//             buttonText: "Continue",
//             onTap: () {
//
//             },
//           ),
//         ],
//       ).marginSymmetric(horizontal: 20.w, vertical: 20.h),
//     );
//   }
// }
