import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/retailers.dart';
import '../model/user.dart';
import '../screens/screen_module.dart';
import '../screens/screen_sign_in.dart';

class ControllerAuthentication extends GetxController {
  var isLoading = false.obs;
  var phoneNo = TextEditingController().obs;
  var posid = TextEditingController().obs;
  var password = TextEditingController().obs;
  var phoneAuthError = ''.obs;
  var selectedAsset = TextEditingController().obs;
  var retailerAddress = TextEditingController().obs;
  var retailerName = TextEditingController().obs;
  var assetCamp = TextEditingController().obs;
  var fid = TextEditingController().obs; // User fid
  var address = ''.obs;
  var selectedRetailerDetail = TextEditingController().obs;
  var images = <String>[].obs;
  var isPresent = false.obs;
  var retailersList = <RetailerModel>[].obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Timer? sessionTimer;
  final int sessionTimeoutDuration = 60 * 60;

  @override
  @override
  void onClose() {
    clearTextControllers();
    cancelSessionTimer();
    super.onClose();
  }

  void onSelected(String value) {
    selectedAsset.value.text = value;
    selectedItem = value;
    update();
  }

  void onImagePicked(String imagePath) {
    if (!images.contains(imagePath) && images.length < 6) {
      images.add(imagePath);
    }
  }


  var selectedRetailerDetails = <String>[].obs;
  final List<String> retailerDetails = [
    'Facia', 'Wall paint', 'In store branding', "OOH", "Others(Specify)", "BTL activity", "Dedicated shop"
  ];
  final List<String> assetsCamp = [
    'Jazz', 'Zong', 'Telenor', "Ufone", "Others"
  ];

  String? selectedItem;
  String? selectedDetails;

  // Method to handle multiple selections
  void onSelectedRetailer(String value) {
    if (selectedRetailerDetails.contains(value)) {
      selectedRetailerDetails.remove(value);  // Remove if already selected
    } else {
      selectedRetailerDetails.add(value);  // Add to list if not selected
    }
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
    if (images.length >= 6) {
      Get.snackbar("Limit Reached", "You can only upload 6 images.", backgroundColor: Colors.red);
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      try {
        String downloadUrl = await uploadImageToStorage(imageFile);
        onImagePicked(downloadUrl); // Only add unique image paths
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
    posid.value.clear();
    selectedAsset.value.clear();
    retailerAddress.value.clear();
    retailerName.value.clear();
    assetCamp.value.clear();
    fid.value.clear();
    selectedRetailerDetail.value.clear();
  }

  // save user fid
  Future<void> saveUserFid(String fidValue) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_fid', fidValue);
    log('User fid saved: $fidValue');
  }

  // add user data through the app
  Future<void> addUserDetailsFromMobile(User user, List<Map<String, dynamic>> modulesData) async {
    try {
      // Save user to Firestore if not already saved
      await _firestore.collection('users').doc(user.userId).set(user.toMap(), SetOptions(merge: true)); // Merge to avoid overwriting existing user data

      // Save fid to SharedPreferences
      await saveUserFid("${user.fid}");

      log("User saved successfully!");

      // Save details as a subcollection for the user
      for (Map<String, dynamic> module in modulesData) {
        String moduleName = module['moduleName']; // Extract module name dynamically
        Map<String, dynamic> moduleData = module['moduleData']; // Extract module data

        await _firestore
            .collection('users')
            .doc(user.userId)
            .collection('modules')
            .doc(moduleName)
            .set(moduleData, SetOptions(merge: true)); // Merge to update existing module data

        log("$moduleName saved successfully!");
      }
    } catch (error) {
      log("Failed to save user or details: $error");
    }
  }

  // Upload custom module data by moduleName
  Future<void> uploadModuleData(String moduleName, Map<String, dynamic> moduleData) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId != null) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('modules')
            .doc(moduleName)
            .set(moduleData, SetOptions(merge: true));
        Get.snackbar("Success", "$moduleName data uploaded successfully!", backgroundColor: Colors.green);
      } else {
        Get.snackbar("Error", "User ID not found. Please log in again.", backgroundColor: Colors.red);
      }
    } catch (error) {
      log("Failed to upload module data: $error");
      Get.snackbar("Error", "Failed to upload module data.", backgroundColor: Colors.red);
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
  // Login Process
  Future<void> verifyPhoneNumber() async {
    isLoading.value = true;

    try {
      log("Verifying phone number: ${phoneNo.value.text}");

      bool isWhitelisted = await checkIfPhoneNumberIsWhitelisted(phoneNo.value.text, password.value.text);

      if (!isWhitelisted) {
        Get.snackbar("Error", "Your phone number is not allowed to access this app.", backgroundColor: Colors.red, snackPosition: SnackPosition.TOP, colorText: Colors.black);
        return;
      }

    } catch (e) {
      log('Error verifying phone number: $e');
      Get.snackbar("Error", "Failed to verify phone number.", backgroundColor: Colors.red, snackPosition: SnackPosition.TOP, colorText: Colors.black);
    } finally {
      isLoading.value = false;
    }
  }
  // check phone Number
  Future<bool> checkIfPhoneNumberIsWhitelisted(String phoneNo, String password) async {
    if (phoneNo.isEmpty || password.isEmpty) {
      log('Error: Phone number or fid is empty.');
      return false;
    }

    try {
      var result = await _firestore.collection('users')
          .where('phoneNumber', isEqualTo: phoneNo)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();
      if (result.docs.isNotEmpty) {
        String userId = result.docs.first.id; // Get user ID from the document ID
        await saveUserId(userId); // Save user ID in SharedPreferences

        log('Phone number is whitelisted and fid matches.');
        Get.snackbar("Success", "Congrats!! Your phoneNo is WhiteListed!", backgroundColor: Colors.green, snackPosition: SnackPosition.TOP, colorText: Colors.black);
        Get.offAll(ScreenModule());
        return true;
      } else {
        log('Phone number is not whitelisted or fid does not match.');
        return false;
      }
    } catch (e) {
      log('Error checking whitelist: $e');
      return false;
    }
  }

  //save userID
  Future<void> saveUserId(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    log('User ID saved: $userId');
  }
  // Fetch retailer usig POSID
  Future<void> searchRetailersByPosId(String posId) async {
    try {
      isLoading(true); // Show loading indicator
      QuerySnapshot querySnapshot = await _firestore
          .collection('retailers')
          .where('posId', isEqualTo: posId) // Search by POS ID
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var retailerData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        retailerName.value.text = retailerData['retailerName'] ?? '';
        retailerAddress.value.text = retailerData['retailerAddress'] ?? '';
      } else {
        Get.snackbar('No Retailer Found', 'No retailer found with this POS ID', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      }
    } catch (e) {
      log("ERROR to fetch retailer $e");
      Get.snackbar('Error', 'Failed to search retailers: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false); // Hide loading indicator
    }
  }

  /// Mark attendance
  void markAttendance(bool isPresentValue) {
    isPresent.value = isPresentValue;
  }
  //screen navigation
  void goToScreenModule() {
    Get.to(() => ScreenModule());
  }
  // logout
  Future<void> logOutUser() async {
    isLoading(true); // Show loading indicator
    try {
      // Clear user-related data
      clearTextControllers();
      cancelSessionTimer();
      await Future.delayed(Duration(seconds: 2));
      Get.offAll(() => ScreenLogin());

      Get.snackbar("Logged Out", "You have successfully logged out.", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green);
    } catch (e) {
      log("Error during logout: $e");
      Get.snackbar("Error", "Failed to log out.", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    } finally {
      isLoading(false);
    }
  }
}
