import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_practices/screens/screen_home.dart';
import 'package:flutter_practices/screens/screen_show_database_data.dart';
import 'package:flutter_practices/screens/screen_sign_in.dart';
import 'package:flutter_practices/utils/firebase_utils.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/firebase_utils.dart';
import '../screens/screen_add_information.dart';

class ControllerRegister extends GetxController {
  var email = TextEditingController().obs;
  var password = TextEditingController().obs;
  var isLoading = false.obs;

  Future<void> register() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    isLoading.value = true;

    try {
      if (email.value.text.isNotEmpty && password.value.text.isNotEmpty) {
        UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email.value.text,
          password: password.value.text,
        );
        String? token = await userCredential.user?.getIdToken();
        if (token != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('userToken', token);
          log("user token == $token");
        }
        Get.offAll(ScreenShowDatabaseData());
        FirebaseUtils.showSuccess("User Registered Successfully");

      } else {
        FirebaseUtils.showError("Please fill out all fields");
      }
    } catch (e) {
      FirebaseUtils.showError("Error: $e");
      log("Error while registering user", error: e);
    } finally {
      isLoading.value = false;
    }
  }
  void logout() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    Future.delayed(Duration(
      seconds: 3
    ));
    try {
      await auth.signOut();
      log("User logged out successfully");

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('userToken');
      Get.offAll(ScreenLogin());
    } catch (e) {
      FirebaseUtils.showError("Error: $e");
      log("Error during logout", error: e);
    }
  }
  Future<void> login() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    isLoading.value = true;

    try {
      if (email.value.text.isNotEmpty && password.value.text.isNotEmpty) {
        UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email.value.text,
          password: password.value.text,
        );
        String? token = await userCredential.user?.getIdToken();
        if (token != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('userToken', token);
          log("User token saved: $token");
        }
        Get.to(ScreenShowDatabaseData());
        FirebaseUtils.showSuccess("User Logged In Successfully");
      } else {
        FirebaseUtils.showError("Please fill out all fields");
      }
    } catch (e) {
      FirebaseUtils.showError("Error: $e");
      log("Error while logging in user", error: e);
    } finally {
      isLoading.value = false;
    }
  }
}
