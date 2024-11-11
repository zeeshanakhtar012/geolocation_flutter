// import 'package:Jazz/screens/screen_module.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'dart:math';
//
// class AuthController extends GetxController {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   // Observable to handle session expiration
//   Rxn<User> firebaseUser = Rxn<User>();
//   RxBool isLoggedIn = false.obs;
//   DateTime? sessionStartTime;
//
//   // Email-based OTP system
//   Future<void> sendOtp(String email) async {
//     int otpCode = _generateOtp();
//     await _firestore.collection('otps').doc(email).set({'otp': otpCode});
//
//     // Email sending logic here (e.g., use an SMTP client or Firebase Functions)
//     await _sendEmailOtp(email, otpCode);
//   }
//
//   int _generateOtp() => Random().nextInt(9000) + 1000;
//
//   Future<void> _sendEmailOtp(String email, int otpCode) async {
//     // Implement your email sending logic here.
//   }
//
//
//
//
//   // Single-device login and logout
//   Future<void> loginUser(String phoneNumber, String password) async {
//     QuerySnapshot snapshot = await _firestore.collection('users')
//         .where('phoneNumber', isEqualTo: phoneNumber)
//         .where('password', isEqualTo: password)
//         .limit(1)
//         .get();
//
//     if (snapshot.docs.isNotEmpty) {
//       // Check if user is already logged in
//       DocumentSnapshot userDoc = snapshot.docs.first;
//       bool isAlreadyLoggedIn = userDoc['isLoggedIn'] ?? false;
//
//       if (isAlreadyLoggedIn) {
//         throw Exception("User already logged in on another device.");
//       }
//
//       // Mark user as logged in and set session expiration time
//       await userDoc.reference.update({'isLoggedIn': true});
//       sessionStartTime = DateTime.now();
//       isLoggedIn.value = true;
//       firebaseUser.value = _auth.currentUser;
//
//       // Start session timer
//       _autoLogoutAfterTimeout();
//     } else {
//       throw Exception("Invalid phone number or password.");
//     }
//   }
//
//   void _autoLogoutAfterTimeout() {
//     Future.delayed(Duration(hours: 1), () {
//       logoutUser();
//     });
//   }
//
//   Future<void> logoutUser() async {
//     if (firebaseUser.value != null) {
//       String uid = firebaseUser.value!.uid;
//
//       // Update Firestore user record to mark as logged out
//       await _firestore.collection('users').doc(uid).update({'isLoggedIn': false});
//
//       // Clear session data
//       firebaseUser.value = null;
//       isLoggedIn.value = false;
//       sessionStartTime = null;
//     }
//   }
//
//   // Function to check if session is still valid
//   bool get isSessionValid {
//     if (sessionStartTime == null) return false;
//     return DateTime.now().difference(sessionStartTime!).inHours < 1;
//   }
// }
