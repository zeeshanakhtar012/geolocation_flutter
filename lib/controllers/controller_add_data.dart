import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/random_otp_genrator.dart';
import '../model/retailers.dart';
import '../model/user.dart';
import '../screens/screen_module.dart';
import '../screens/screen_otp.dart';
import '../screens/screen_sign_in.dart';

class ControllerAuthentication extends GetxController {
  // others field data
  RxBool showOthersInput = false.obs;
  var isLoading = false.obs;
  var phoneNo = TextEditingController().obs;
  var othersController = TextEditingController().obs;
  var posid = TextEditingController().obs;
  var password = TextEditingController().obs;
  var otp = TextEditingController().obs;
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
  RxString retailerNameHint = ''.obs;
  RxString retailerAddressHint = ''.obs;

  RxInt timeRemaining = 3600.obs;
  Rx<User?> user = Rx<User?>(null);

  late Timer countdownTimer;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Timer? sessionTimer;
  final int sessionTimeoutDuration = 60 * 60;
  int attemptCount = 0;
  final int maxAttempts = 5;

  /// Check if user is already logged in
  // Inside your verifyPhoneNumber or login function
  Future<void> verifyPhoneNumber() async {
    isLoading.value = true;

    try {
      bool isWhitelisted = await checkIfPhoneNumberIsWhitelisted(
          phoneNo.value.text, password.value.text);

      if (!isWhitelisted) {
        Get.snackbar("Error", "Your phone number is not allowed to access this app.",
            backgroundColor: Colors.red);
        return;
      }

      var result = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNo.value.text)
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        var userData = result.docs.first.data();
        String? savedDeviceToken = userData['deviceToken'];
        String currentDeviceToken = await getCurrentDeviceToken();

        if (savedDeviceToken != null &&
            savedDeviceToken.isNotEmpty &&
            savedDeviceToken != currentDeviceToken) {
          Get.snackbar("Error", "This phone number is already logged in on another device.",
              backgroundColor: Colors.red);
          log("${savedDeviceToken.toString()}");
          return;
        }
      }

      // Save the login timestamp in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('loginTimestamp', DateTime.now().millisecondsSinceEpoch);

      startSessionTimer();

      String otp = await sendOtp();
      showOtpDialog(otp);
    } catch (e) {
      log('Error verifying phone number: $e');
      Get.snackbar("Error", "Failed to verify phone number.",
          backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }
  // logout automatically
  void startSessionTimer() {
    sessionTimer?.cancel();

    sessionTimer = Timer(Duration(seconds: sessionTimeoutDuration), () {
      logOutUserAutomatically();
      logOutUser();
    });
  }

  Future<void> checkSessionValidity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? loginTimestamp = prefs.getInt('loginTimestamp');

    if (loginTimestamp != null) {
      int currentTime = DateTime.now().millisecondsSinceEpoch;
      int elapsedTime = (currentTime - loginTimestamp) ~/ 1000;

      if (elapsedTime >= sessionTimeoutDuration) {
        logOutUserAutomatically();
      } else {
        // Session is still valid, calculate remaining time
        int remainingTime = sessionTimeoutDuration - elapsedTime;
        sessionTimer = Timer(Duration(seconds: remainingTime), () {
          logOutUserAutomatically();
        });
      }
    } else {
      // No valid session found, redirect to login
      Get.offAll(() => ScreenLogin());
    }
  }

  Future<void> logOutUserAutomatically() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('loginTimestamp'); // Remove the stored timestamp

    Get.snackbar(
      "Session Expired",
      "You have been logged out due to inactivity.",
      backgroundColor: Colors.red,
      colorText: Colors.black,
    );
    await logOutUser();
    Get.offAll(() => ScreenLogin()); // Redirect to login screen
  }

  // chekc phone number
  Future<bool> checkIfPhoneNumberIsWhitelisted(
      String phoneNo, String password) async {
    if (phoneNo.isEmpty || password.isEmpty) {
      log('Error: Phone number or password is empty.');
      return false;
    }

    try {
      var result = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNo)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        String userId =
            result.docs.first.id; // Get user ID from the document ID
        await saveUserId(userId);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log('Error checking phone number: $e');
      return false;
    }
  }
  // get current user token
  Future<String> getCurrentDeviceToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? deviceToken = prefs.getString('deviceToken');

    try {
      if (deviceToken == null || deviceToken.isEmpty) {
        deviceToken = await FirebaseMessaging.instance.getToken();
        if (deviceToken == null || deviceToken.isEmpty) {
          throw Exception("Device token is null or empty");
        }
        await prefs.setString('deviceToken', deviceToken);
      }
    } catch (e) {
      log("Error retrieving device token: $e");
      rethrow; // Ensure the calling method is aware of this failure
    }

    return deviceToken;
  }
  // verify otp
  Future<void> verifyOtp(String enteredOtp) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('otps').doc(phoneNo.value.text).get();

      if (snapshot.exists && snapshot['otp'] == enteredOtp) {
        Get.snackbar("Success", "OTP verified successfully!", backgroundColor: Colors.green);

        await deleteOtpFromFirestore();

        // After successfully deleting OTP, navigate to ScreenModule
        await updateUserDeviceToken(phoneNo.value.text, await getCurrentDeviceToken());

        // Start the session timer now that the user is logged in
        startSessionTimer();

        Get.offAll(ScreenModule()); // Use Get.offAll to clear the navigation stack
        log("OTP deleted Successfully!");
      } else {
        Get.snackbar("Error", "Invalid OTP. Please try again.", backgroundColor: Colors.red);
      }
    } catch (e) {
      log('Error verifying OTP: $e');
      Get.snackbar("Error", "Failed to verify OTP.", backgroundColor: Colors.red);
    }
  }
  //
  Future<void> deleteOtpFromFirestore() async {
    try {
      await _firestore.collection('otps').doc(phoneNo.value.text).delete();
      log('OTP deleted from Firestore for phone number: ${phoneNo.value.text}');
    } catch (e) {
      log('Error deleting OTP from Firestore: $e');
    }
  }

  Future<String> sendOtp() async {
    String otp = generateOTP(); // Assume generateOTP() generates a new OTP
    try {
      // Save OTP to Firestore
      await _firestore.collection('otps').doc(phoneNo.value.text).set({
        'otp': otp,
        'createdAt': FieldValue.serverTimestamp(),
      });

      attemptCount++;
      return otp;
    } catch (e) {
      Get.snackbar("Error", "Failed to send OTP: $e",
          backgroundColor: Colors.red);
      return '';
    }
  }

  Future<void> showOtpDialog(String otp) {
    return showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        int secondsRemaining = 60;
        Timer? timer;

        timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
          if (secondsRemaining == 0) {
            deleteOtpFromFirestore();
            timer.cancel();
            Get.back();
          } else {
            secondsRemaining--;
          }
        });

        return AlertDialog(
          title: Text("Your OTP Code"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Your OTP is: $otp",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 18.sp,
                ),
              ),
              SizedBox(height: 20),
              Text("This OTP will expire in $secondsRemaining seconds",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                timer?.cancel();
                Get.to(ScreenVerifyOtp());
              },
              child: Text("Verify Otp"),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateUserDeviceToken(String phoneNo, String deviceToken) async {
    try {
      var result = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNo)
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        String userId = result.docs.first.id;
        await _firestore.collection('users').doc(userId).update({
          'deviceToken': deviceToken, // Update the device token
        });
        log('Device token updated for user: $userId');
      } else {
        log('User not found for phone number: $phoneNo');
      }
    } catch (e) {
      log('Error updating device token: $e');
    }
  }
  // Logout user automatically
  @override
  void onClose() {
    // Reset all variables to their default values
    selectedRetailerDetails.clear();
    chooseOne.value = ''; // Resetting to default
    showOthersInput.value = false; // Resetting to default
    othersController.value.clear(); // Clearing the TextEditingController
    super.onClose();
    // sessionTimer?.cancel();
    // clearTextControllers(); // Ensure all data is cleared
    startSessionTimer();
    super.onClose();
  }
  // Save user ID in SharedPreferences
  Future<void> saveUserId(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    log('User ID saved: $userId');
  }
  Future<String?> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    log('Retrieved User ID: $userId');
    return userId;
  }

  Future<void> clearTextControllers() async {
    // Clear all TextEditingController values
    phoneNo.value.clear();
    posid.value.clear();
    selectedAsset.value.clear();
    retailerAddress.value.clear();
    retailerName.value.clear();
    assetCamp.value.clear();
    fid.value.clear();
    selectedRetailerDetail.value.clear();
    otp.value.clear();
    password.value.clear();
    othersController.value.clear();

    // Clear observable variables and lists
    phoneAuthError.value = '';
    address.value = '';
    retailerNameHint.value = '';
    retailerAddressHint.value = '';
    images.clear();
    retailersList.clear();

    // Reset booleans and other observables
    showOthersInput.value = false;
    isLoading.value = false;
    isPresent.value = false;

    update(); // Notify listeners about UI updates
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
  var chooseOne = ''.obs;
  final List<String> retailerDetails = [
    'Facia',
    'Wall paint',
    'In store branding',
    "OOH",
    "Others (Specify)",
    "BTL activity",
    "Dedicated shop"
  ];
  final List<String> assetsCamp = [
    'Jazz',
    'Zong',
    'Telenor',
    "Ufone",
    "Others"
  ];

  String? selectedItem;
  String? selectedDetails;

  void onSelectedRetailer(String value) {
    if (selectedRetailerDetails.contains(value)) {
      selectedRetailerDetails.remove(value);
      if (value == "Others (Specify)") {
        showOthersInput.value = false;
        othersController.value.clear();
      }
    } else {
      selectedRetailerDetails.add(value);
      if (value == "Others (Specify)") {
        showOthersInput.value = true;
      }
    }
    update();
  }
  void chooseOneOption(String value) {
    // Directly update the chooseOne to the selected value
    chooseOne.value = value;

    // If "Others (Specify)" is selected, show the input field, else hide it
    if (value == "Others (Specify)") {
      showOthersInput.value = true;
    } else {
      showOthersInput.value = false;
    }

    // Clear the "Others" input field if something other than "Others (Specify)" is selected
    if (value != "Others (Specify)") {
      othersController.value.clear();
    }

    // Trigger UI update
    update();
  }
  /// Pick and Upload Image
  Future<void> pickAndUploadImage() async {
    if (images.length < 6) {
      Get.snackbar("Error", "You have to upload 6 images!",
          backgroundColor: Colors.red);
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
  // Get modules Data
  Future<void> fetchModuleData(String moduleName) async {
    try {
      // Retrieve userId from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId != null) {
        // Reference to the Firestore collection path
        CollectionReference dataByDateCollection = _firestore
            .collection('users')
            .doc(userId)
            .collection('modules')
            .doc(moduleName)
            .collection('dataByDate');

        // Fetch all documents from the dataByDate collection
        QuerySnapshot querySnapshot = await dataByDateCollection.get();

        // Process and print each document's data
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          log("Document ID: ${doc.id}, Data: $data");

          // Optionally, process each document's data here
          // For example, store it in a list, display it in the UI, etc.
        }

        Get.snackbar("Success", "Module data fetched successfully!",
            backgroundColor: Colors.green);
      } else {
        Get.snackbar("Error", "User ID not found. Please log in again.",
            backgroundColor: Colors.red);
      }
    } catch (error) {
      log("Failed to fetch module data: $error");
      Get.snackbar("Error", "Failed to fetch module data.",
          backgroundColor: Colors.red);
    }
  }
// upload modules Data

  Future<void> uploadModuleData(
      String moduleName, Map<String, dynamic> moduleData) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId != null) {
        // Get current date and time as unique identifier
        String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
        String formattedTime = DateFormat('HH-mm-ss').format(DateTime.now());
        String documentId =
            '$formattedDate-$formattedTime'; // Combine date and time for uniqueness

        await _firestore
            .collection('users')
            .doc(userId)
            .collection('modules')
            .doc(moduleName)
            .collection('dataByDate')
            .doc(documentId)
            .set(moduleData);
        log("$moduleName data uploaded with unique timestamp!");
        Get.snackbar("Success", "$moduleName data uploaded successfully!",
            backgroundColor: Colors.green);
        Get.offAll(ScreenModule());
      } else {
        Get.snackbar("Error", "User ID not found. Please log in again.",
            backgroundColor: Colors.red);
      }
    } catch (error) {
      log("Failed to upload module data: $error");
      Get.snackbar("Error", "Failed to upload module data.",
          backgroundColor: Colors.red);
      // await clearTextControllers();
    }
  }
  // retailers details
  Future<void> searchRetailersByPosId(String posId) async {
    try {
      isLoading(true);
      QuerySnapshot querySnapshot = await _firestore
          .collection('retailers')
          .where('posId', isEqualTo: posId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var retailerData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        retailerNameHint.value = retailerData['retailerName'] ?? 'No Name';
        retailerAddressHint.value = retailerData['retailerAddress'] ?? 'No Address';
        log('Retailer Name: ${retailerData['retailerName']}');
        log('Retailer Address: ${retailerData['retailerAddress']}');

        Get.snackbar(
          'Success',
          'Retailer details fetched successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
        );
      } else {
        retailerNameHint.value = '';
        retailerAddressHint.value = '';
        Get.snackbar(
          'No Retailer Found',
          'No retailer found with this POS ID',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      log("ERROR to fetch retailer $e");
      Get.snackbar(
        'Error',
        'Failed to search retailers: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
      // await clearTextControllers();
    }
  }
  /// Mark attendance
  void markAttendance(bool isPresentValue) {
    isPresent.value = isPresentValue;
  }


  Future<void> logOutUser() async {
    isLoading(true);
    try {
      // Get the saved user ID from SharedPreferences
      String? userId = await getUserId();

      if (userId != null && userId.isNotEmpty) {
        // Remove the device token from Firestore
        await FirebaseFirestore.instance
            .collection('users') // Adjust collection name to match your structure
            .doc(userId)
            .update({
          'deviceToken': FieldValue.delete(), // Remove the device token field
        })
            .then((value) => log("Device token deleted successfully"))
            .catchError((error) => log("Failed to delete device token: $error"));
      }

      // Clear user-related data
      // clearTextControllers();
      sessionTimer?.cancel();
      await Future.delayed(Duration(seconds: 2));

      // Navigate to login screen
      Get.offAll(() => ScreenLogin());

      // Show success message
      Get.snackbar("Logged Out", "You have successfully logged out.",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green);
    } catch (e) {
      log("Error during logout: $e");
      Get.snackbar("Error", "Failed to log out.",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchUserDetails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId != null) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('userId', isEqualTo: userId)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          var userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
          log('Fetched User Data: $userData'); // Log fetched user data

          // Use the factory method to create the User object
          User userValue = User.fromDocumentSnapshot(userData);
          log('User name = ${userValue.userName}'); // Log the user name

          // Assuming you have a reactive variable to store user info
          user.value = userValue; // Assign the user to your reactive variable
        } else {
          Get.snackbar('No User Found', 'No user found with this ID',
              snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
        }
      } else {
        Get.snackbar("Error", "User ID not found. Please log in again.",
            backgroundColor: Colors.red);
      }
    } catch (e) {
      log("Failed to fetch user details: $e");
      Get.snackbar("Error", "Failed to fetch user details.",
          backgroundColor: Colors.red);
    }
  }
}
