import 'dart:io';


import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';


class FirebaseUtils {
  // String image=uploadImage(filePath, firebasePathWithFilename)
  static Future<String> uploadImage(
      String filePath, String firebasePathWithFilename,
      {Function(String url)? onSuccess,
      Function(String error)? onError,
      Function(double progress)? onProgress}) async {
    Reference storageReference =
        FirebaseStorage.instance.ref().child(firebasePathWithFilename);
    final UploadTask uploadTask = storageReference.putFile(File(filePath));

    uploadTask.snapshotEvents.listen((event) {
      double progress =
          event.bytesTransferred.toDouble() / event.totalBytes.toDouble();
      if (onProgress != null) {
        // onProgress(progress.roundToNum(2));
      }
    }).onError((error) {
      // do something to handle error
      if (onError != null) {
        onError(error.toString());
      }
    });

    final TaskSnapshot downloadUrl = (await uploadTask);
    final String url = await downloadUrl.ref.getDownloadURL();
    if (onSuccess != null) {
      print(url);
      onSuccess(url);
    }
    return url;
  }

  static Future<List<String>> uploadMultipleImage(
      List<String> imagesPaths, String firebasePathWithFilenameWithoutExtension,
      {Function(int which, double progress)? onProgress,
      required String extension}) async {
    if (imagesPaths.isEmpty) {
      return [];
    }

    List<String> urls = [];

    await Future.forEach(imagesPaths, (String path) async {
      int index = imagesPaths.indexOf(path);
      var url = await uploadImage(path,
          "${firebasePathWithFilenameWithoutExtension}_${index}.$extension",
          onProgress: (progress) {
        if (onProgress != null) {
          onProgress(index, progress);
        }
      });
      urls.add(url);
    });

    return urls;
  }

  // static String get myId =>
  //     Get.find<ControllerHome>().user.value!.user.id.toString();

  // static int get myIntId =>
  //     Get.find<ControllerHome>().user.value!.user.id!;

  // static String get myName =>
  //     Get.find<ControllerHome>().user.value!.user=="couple"?"${Get.find<ControllerHome>().user.value!.user.partner1Name}&${Get.find<ControllerHome>().user.value!.user.partner2Name}":"${Get.find<ControllerHome>().user.value!.user.fName}";
  //
  // static String get myToken => Get.find<ControllerHome>()
  //     .user
  //     .value!
  //     .user
  //     .deviceToken?? "";
  //
  // static String get myImage =>
  //     "${APiEndPoint.imageUrl}${Get.find<ControllerHome>().user.value!.user.userType=="couple"?Get.find<ControllerHome>().user.value!.user.coupleRecentImage!.userRecentImages.first:Get.find<ControllerHome>().user.value!.user.singleRecentImage!.userRecentImages!.first!}";

  static int get newId => DateTime.now().millisecondsSinceEpoch;
  static showError(String message) {
    Get.snackbar(
      "Error",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      borderRadius: 20,
      margin:  EdgeInsets.symmetric(vertical:35.h,horizontal: 15.w),
      duration: const Duration(seconds: 3),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeIn,
      icon: const Icon(Icons.error, color: Colors.white),
      shouldIconPulse: true,
      // leftBarIndicatorColor: Colors.red,
      padding:  EdgeInsets.symmetric(vertical: 25.h,horizontal: 10.w
      ),

    );
  }
  static showSuccess(String message) {
    Get.snackbar(
      "Success",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      borderRadius: 20,
      margin:  EdgeInsets.symmetric(vertical:35.h,horizontal: 15.w),
      duration: const Duration(seconds: 3),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeIn,
      icon: const Icon(Icons.check, color: Colors.white),
      shouldIconPulse: true,
    padding:  EdgeInsets.symmetric(vertical: 25.h,horizontal: 10.w
    )
    );
  }
  int get2ndUserId(String chatRoomId, String myId) {
    // Convert myId to an integer
    int myIdInt = int.parse(myId);

    List<String> ids = chatRoomId.split('_');

    // If the length of ids is not 2, then there's an issue with the input format
    if (ids.length != 2) {
      throw ArgumentError('Invalid chatRoomId format.');
    }

    // Convert the split IDs to integers
    int id1 = int.parse(ids[0]);
    int id2 = int.parse(ids[1]);

    // Determine which ID is not myIdInt
    if (id1 == myIdInt) {
      return id2; // Return the second ID as a string
    } else if (id2 == myIdInt) {
      return id1; // Return the first ID as a string
    } else {
      throw ArgumentError('myId not found in chatRoomId.');
    }
  }
  static String convertMillisToTimeString(int millisSinceEpoch) {
    // Convert the milliseconds since epoch to a DateTime object
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(millisSinceEpoch);

    // Format the DateTime object to the desired format (e.g., "7:30 AM")
    String formattedTime = DateFormat('h:mm a').format(dateTime);

    return formattedTime;
  }
}
