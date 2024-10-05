import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io'; // For handling files
import 'package:firebase_storage/firebase_storage.dart'; // Add Firebase Storage
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart'; // For picking images
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/screen_module.dart';
import '../screens/screen_sign_in.dart';

class ControllerAuthentication extends GetxController {
  var isLoading = false.obs;
  var lat = 0.0.obs;
  var lng = 0.0.obs;
  var phoneNo = TextEditingController().obs;
  var phoneAuthError = ''.obs;
  var posId = TextEditingController().obs;
  var retailerName = TextEditingController().obs;
  var retailerAddress = TextEditingController().obs;
  var selectedAsset = TextEditingController().obs;
  var assetCamp = TextEditingController().obs;
  var selectedRetailerDetail = TextEditingController().obs;
  var images = <String>[].obs;
  var isPresent = false.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Timer? sessionTimer;
  final int sessionTimeoutDuration = 60 * 60;

  @override
  void onClose() {
    cancelSessionTimer();
    phoneNo.value.dispose();
    super.onClose();
  }

  void startSessionTimer() {
    sessionTimer?.cancel();
    sessionTimer = Timer(Duration(seconds: sessionTimeoutDuration), () {
      logOutUserAutomatically();
    });
  }

  void cancelSessionTimer() {
    sessionTimer?.cancel();
  }

  /// Method to pick an image and upload it to Firebase Storage
  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      try {
        // Upload image to Firebase Storage
        String downloadUrl = await uploadImageToStorage(imageFile);
        images.add(downloadUrl); // Add the download URL to the images list
        log('Image uploaded and URL stored: $downloadUrl');
      } catch (e) {
        log('Error uploading image: $e');
      }
    }
  }

  /// Uploads the selected image to Firebase Storage and returns the download URL
  Future<String> uploadImageToStorage(File imageFile) async {
    log("Images uploaded successfully: $images");
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageRef = _storage.ref().child('images/$fileName');
    UploadTask uploadTask = storageRef.putFile(imageFile);

    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

  /// Save data including image URLs and attendance to Firestore
  Future<void> saveData(double lat, double lng) async {
    try {
      startSessionTimer();
      CollectionReference users = _firestore.collection('users');
      await users.add({
        'latitude': lat,
        'longitude': lng,
        'timestamp': FieldValue.serverTimestamp(),
        'posId': posId.value.text,
        'phoneNo': phoneNo.value.text,
        'retailerName': retailerName.value.text,
        'retailerAddress': retailerAddress.value.text,
        'selectedAsset': selectedAsset.value.text,
        'assetCamp': assetCamp.value.text,
        'selectedRetailerDetail': selectedRetailerDetail.value.text,
        'images': images.isNotEmpty ? images : [],
        'isPresent': isPresent.value,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Selected Asset: ${selectedAsset.value.text}');
      print('POSID: ${posId.value.text}');
      print('Name: ${retailerName.value.text}');
      print('Selected Asset camp: ${assetCamp.value.text}');
      print('selectedRetailerDetail Asset: ${selectedRetailerDetail.value.text}');
      print('Selected Asset: ${images.isNotEmpty ? images : []}');
      print('Selected Asset: ${isPresent.value}');
      print('Address: ${retailerAddress.value.text}');
      print('isPresent: $isPresent');
      print('Latitude: $lat');
      print('Longitude: $lng');
      print('Phone No: $phoneNo');
      log('Location, images, and attendance status saved successfully');
      Get.snackbar("Success", "Data uploaded successfully!", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green);
    } catch (error) {
      log('Failed to save data: $error');
    }
  }

  Future<void> logOutUserAutomatically() async {
    try {
      Get.snackbar("Session Expired", "You have been logged out due to inactivity.");
      Get.offAll(() => ScreenLogin());
    } catch (e) {
      log("Error logging out: $e");
    }
  }

  Future<void> getLocation() async {
    const String url = 'https://www.gomaps.pro/geolocation/v1/geolocate?key=AlzaSyfeW0nR9wzFCtGWE_JoHuAfPJmT7Cg9z0I';
    isLoading.value = true;

    try {
      final response = await http.post(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        lat.value = data['location']['lat'];
        lng.value = data['location']['lng'];
        await saveData(lat.value, lng.value);
      } else {
        log('Failed to get location: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching location: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyPhoneNumber() async {
    isLoading.value = true;

    try {
      bool isWhitelisted = await checkIfPhoneNumberIsWhitelisted(phoneNo.value.text);
      if (!isWhitelisted) {
        Get.snackbar("Error", "Your phone number is not allowed to access this app.");
        return;
      }
      Get.offAll(() => ScreenModule());
    } catch (e) {
      log('Error verifying phone number: $e');
      Get.snackbar("Error", "Failed to verify phone number.");
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> checkIfPhoneNumberIsWhitelisted(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      log('Error: Phone number is empty.');
      return false;
    }

    try {
      var result = await _firestore
          .collection('phoneNo')
          .where('phoneNo', isEqualTo: phoneNumber)
          .get();
      return result.docs.isNotEmpty;
    } catch (e) {
      log('Error checking whitelist: $e');
      return false;
    }
  }

  /// Method to mark attendance
  void markAttendance(bool isPresentValue) {
    isPresent.value = isPresentValue; // Update attendance status
  }

  /// Method to save attendance status to Firestore
  Future<void> saveAttendanceStatus() async {
    if (!isPresent.value) {
      Get.snackbar("Error", "You must mark your attendance!", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // Save the attendance status to Firestore
    await saveData(lat.value, lng.value);
    Get.snackbar("Success", "Attendance marked successfully!", snackPosition: SnackPosition.BOTTOM);
  }
}
