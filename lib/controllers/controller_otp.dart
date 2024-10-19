// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cloud_functions/cloud_functions.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:get/get.dart';
// import 'dart:math';
//
// class ControllerOtp extends GetxController {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   var isLoading = false.obs;
//   var emailController = TextEditingController();
//   var otpController = TextEditingController();
//   var phoneNo = TextEditingController().obs; // For phone number field
//
//   String generatedOtp = '';
//   bool isOtpVerified = false; // To track OTP verification status
//
//   // Step 1: Generate a 6-digit OTP
//   String generateOtp() {
//     var random = Random();
//     var otp = '';
//     for (int i = 0; i < 4; i++) {
//       otp += random.nextInt(10).toString();
//     }
//     return otp;
//   }
//
//   // Step 2: Send OTP to the user's email using Firebase Cloud Functions
//   Future<void> sendOtp(String email) async {
//     isLoading.value = true;
//     try {
//       generatedOtp = generateOtp(); // Generate new OTP
//       // Call Firebase Cloud Function to send the OTP via email
//       HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('sendOtpEmail');
//       await callable.call({
//         'email': email,
//         'otp': generatedOtp,
//       });
//
//       // Step 3: Store OTP in Firestore for validation later
//       await storeOtp(email, generatedOtp);
//
//       Get.snackbar('OTP Sent', 'OTP has been sent to your email', snackPosition: SnackPosition.BOTTOM);
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to send OTP: $e', snackPosition: SnackPosition.BOTTOM);
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   // Step 3: Store OTP in Firestore with timestamp
//   Future<void> storeOtp(String email, String otp) async {
//     await _firestore.collection('otps').doc(email).set({
//       'otp': otp,
//       'timestamp': FieldValue.serverTimestamp(),
//     });
//   }
//
//   // Step 4: Verify the OTP entered by the user
//   Future<bool> verifyOtp(String enteredOtp) async {
//     String email = emailController.text.trim(); // Get email from the controller
//     try {
//       var otpDoc = await _firestore.collection('otps').doc(email).get();
//
//       if (!otpDoc.exists) {
//         Get.snackbar('Invalid OTP', 'No OTP found for this email', snackPosition: SnackPosition.BOTTOM);
//         return false;
//       }
//
//       var data = otpDoc.data();
//       var storedOtp = data?['otp'];
//       var timestamp = data?['timestamp'];
//
//       // Check if OTP is correct and within 10 minutes of creation
//       if (storedOtp == enteredOtp && DateTime.now().difference(timestamp.toDate()).inMinutes < 10) {
//         isOtpVerified = true; // Mark OTP as verified
//         Get.snackbar('OTP Verified', 'OTP is correct. You can now enter your phone number.', snackPosition: SnackPosition.BOTTOM);
//         return true;
//       } else {
//         Get.snackbar('Invalid OTP', 'OTP is incorrect or has expired', snackPosition: SnackPosition.BOTTOM);
//         return false;
//       }
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to verify OTP: $e', snackPosition: SnackPosition.BOTTOM);
//       return false;
//     }
//   }
//
//   // Step 5: Log in the user after OTP verification
//   Future<void> loginUserWithPhone() async {
//     try {
//       isLoading.value = true;
//       String phone = phoneNo.value.text.trim(); // Get phone number from the controller
//
//       // Here you can implement login logic with phone number or save phone number to the database
//       await _firestore.collection('users').doc(emailController.text.trim()).set({
//         'phone': phone,
//       }, SetOptions(merge: true));
//
//       Get.snackbar('Login Successful', 'You have been logged in with phone number', snackPosition: SnackPosition.BOTTOM);
//     } catch (e) {
//       Get.snackbar('Login Failed', 'Failed to log in: $e', snackPosition: SnackPosition.BOTTOM);
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   // Step 6: Invalidate OTP after successful login or after it expires
//   Future<void> invalidateOtp() async {
//     try {
//       String email = emailController.text.trim();
//       await _firestore.collection('otps').doc(email).delete();
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to invalidate OTP: $e', snackPosition: SnackPosition.BOTTOM);
//     }
//   }
//
//   // Step 7: Handle the OTP validation and login process
//   Future<void> handleOtpAndLogin() async {
//     String email = emailController.text.trim();
//     String otp = otpController.text.trim();
//
//     isLoading.value = true;
//
//     // Verify the OTP entered by the user
//     bool isOtpValid = await verifyOtp(otp);
//     if (isOtpValid) {
//       // OTP is correct, proceed with the next step
//       isOtpVerified = true; // Set flag to true to show the phone field in the UI
//     } else {
//       Get.snackbar('Invalid OTP', 'Please enter a valid OTP', snackPosition: SnackPosition.BOTTOM);
//     }
//     isLoading.value = false;
//   }
// }
