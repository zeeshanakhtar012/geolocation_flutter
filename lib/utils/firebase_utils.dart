// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
//
// class FirebaseUtils {
//   static showError(String message) {
//     Get.snackbar(
//       "Error",
//       message,
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: Colors.red,
//       colorText: Colors.white,
//       borderRadius: 20,
//       margin:  EdgeInsets.symmetric(vertical:35.h,horizontal: 15.w),
//       duration: const Duration(seconds: 3),
//       isDismissible: true,
//       dismissDirection: DismissDirection.horizontal,
//       forwardAnimationCurve: Curves.easeOutBack,
//       reverseAnimationCurve: Curves.easeIn,
//       icon: const Icon(Icons.error, color: Colors.white),
//       shouldIconPulse: true,
//       // leftBarIndicatorColor: Colors.red,
//       padding:  EdgeInsets.symmetric(vertical: 25.h,horizontal: 10.w
//       ),
//
//     );
//   }
//   static showSuccess(String message) {
//     Get.snackbar(
//         "Success",
//         message,
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//         borderRadius: 20,
//         margin:  EdgeInsets.symmetric(vertical:35.h,horizontal: 15.w),
//         duration: const Duration(seconds: 3),
//         isDismissible: true,
//         dismissDirection: DismissDirection.horizontal,
//         forwardAnimationCurve: Curves.easeOutBack,
//         reverseAnimationCurve: Curves.easeIn,
//         icon: const Icon(Icons.check, color: Colors.white),
//         shouldIconPulse: true,
//         padding:  EdgeInsets.symmetric(vertical: 25.h,horizontal: 10.w
//         )
//     );
//   }
// }