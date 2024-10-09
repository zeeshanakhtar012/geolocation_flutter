import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io'; // For handling files
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart'; // For picking images
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart'; // For address fetching

import '../screens/screen_module.dart';
import '../screens/screen_sign_in.dart';

class ControllerAuthentication extends GetxController {
  var isLoading = false.obs;
  var phoneNo = TextEditingController().obs;
  var phoneAuthError = ''.obs;
  var posId = TextEditingController().obs;
  var retailerName = TextEditingController().obs;
  var retailerAddress = TextEditingController().obs;
  var selectedAsset = TextEditingController().obs;
  var assetCamp = TextEditingController().obs;
  var address = ''.obs;
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

  void onSelected(String value) {
    selectedAsset.value.text = value;
    selectedItem = value;
    update();
  }

  void onImagePicked(String imagePath) {
    // Only add unique image paths
    if (!images.contains(imagePath)) {
      images.add(imagePath);
    }
  }

  final List<String> retailerDetails = [
    'Facia', 'Wali point', 'In store branding', "OOH", "Others(Specify)", "BTL activity", "Dedicated shop"
  ];

  final List<String> assetsCamp = [
    'Jazz', 'Zong', 'Telenor', "Ufone", "Others"
  ];

  String? selectedItem;
  String? selectedDetails;

  void onSelectedRetailer(String value) {
    selectedDetails = value;
    selectedRetailerDetail.value.text = value;
    update();
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

  /// Pick and Upload Image
  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      try {
        String downloadUrl = await uploadImageToStorage(imageFile);
        onImagePicked(downloadUrl);
        log('Image uploaded and URL stored: $downloadUrl');
      } catch (e) {
        log('Error uploading image: $e');
      }
    }
  }

  /// Uploads images to Firebase Storage
  Future<String> uploadImageToStorage(File imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageRef = _storage.ref().child('images/$fileName');
    UploadTask uploadTask = storageRef.putFile(imageFile);

    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

  /// Clear all input fields
  void clearTextControllers() {
    phoneNo.value.clear();
    posId.value.clear();
    retailerName.value.clear();
    retailerAddress.value.clear();
    selectedAsset.value.clear();
    assetCamp.value.clear();
    selectedRetailerDetail.value.clear();
  }

  /// Save data to Firestore
  Future<void> saveData() async {
    if (phoneNo.value.text.isEmpty || posId.value.text.isEmpty || retailerName.value.text.isEmpty) {
      Get.snackbar("Error", "Please fill in all required fields!", snackPosition: SnackPosition.BOTTOM);
      return;
    }
    try {
      isLoading(true);
      startSessionTimer();
      CollectionReference users = _firestore.collection('users');
      Placemark? placemark = await getAddressFromCurrentLocation();
      String formattedAddress = placemark != null
          ? '${placemark.subLocality}, ${placemark.locality}, ${placemark.country}'
          : 'Address not found';

      log('Current Address: $formattedAddress');

      await users.add({
        'timestamp': FieldValue.serverTimestamp(),
        'posId': posId.value.text,
        'phoneNo': phoneNo.value.text,
        'retailerName': retailerName.value.text,
        'retailerAddress': retailerAddress.value.text,
        'address': address.value,
        'formattedAddress': formattedAddress,
        'selectedAsset': selectedAsset.value.text,
        'assetCamp': assetCamp.value.text,
        'selectedRetailerDetail': selectedRetailerDetail.value.text,
        'images': images.isNotEmpty ? images : [],
        'isPresent': isPresent.value,
      });

      Get.snackbar("Success", "Data uploaded successfully!", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green);
    } catch (error) {
      log('Failed to save data: $error');
    } finally {
      isLoading(false);
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

  /// Verifying phone number with Firestore whitelist
  Future<void> verifyPhoneNumber() async {
    isLoading.value = true;

    try {
      log("Verifying phone number: ${phoneNo.value.text}");
      bool isWhitelisted = await checkIfPhoneNumberIsWhitelisted(phoneNo.value.text);

      if (!isWhitelisted) {
        Get.snackbar("Error", "Your phone number is not allowed to access this app.", backgroundColor: Colors.red, snackPosition: SnackPosition.TOP, colorText: Colors.black);
        return;
      }

      Get.snackbar("Success", "Your phone number is whitelisted.", backgroundColor: Colors.green, snackPosition: SnackPosition.TOP, colorText: Colors.black);
      Get.offAll(() => ScreenModule());
    } catch (e) {
      log('Error verifying phone number: $e');
      Get.snackbar("Error", "Failed to verify phone number.", backgroundColor: Colors.red, snackPosition: SnackPosition.TOP, colorText: Colors.black);
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
          .collection('users')
          .where('phoneNo', isEqualTo: phoneNumber)
          .get();

      return result.docs.isNotEmpty;
    } catch (e) {
      log('Error checking whitelist: $e');
      return false;
    }
  }

  /// Mark attendance
  void markAttendance(bool isPresentValue) {
    isPresent.value = isPresentValue;
  }

  /// Save attendance status in Firestore
  Future<void> saveAttendanceStatus() async {
    if (!isPresent.value) {
      Get.snackbar("Error", "You must mark your attendance!", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      await _firestore.collection('attendance').add({
        'phoneNo': phoneNo.value.text,
        'isPresent': isPresent.value,
        'timestamp': FieldValue.serverTimestamp(),
      });

      Get.snackbar("Success", "Attendance saved successfully!", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green);
    } catch (e) {
      log("Error saving attendance: $e");
    }
  }

  /// Get address from current location
  Future<Placemark?> getAddressFromCurrentLocation() async {
    try {
      var position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      return placemarks.isNotEmpty ? placemarks.first : null;
    } catch (e) {
      log("Error fetching current address: $e");
      return null;
    }
  }
}
