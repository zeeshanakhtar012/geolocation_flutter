import 'dart:developer';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_practices/utils/firebase_utils.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/firebase_utils.dart';
import '../screens/screen_show_database_data.dart';

class ControllerFirebasePosting extends GetxController {
  final dataBase = FirebaseDatabase.instance.ref('jazz');
  var posId = TextEditingController().obs;
  var region = TextEditingController().obs;
  var mbuName = TextEditingController().obs;
  var retailerName = TextEditingController().obs;
  var retailerDetails = TextEditingController().obs;
  var assetCamp = TextEditingController().obs;
  var franchiseId = TextEditingController().obs;
  var isLoading = false.obs;
  var selectedImages = <File>[].obs; // List of selected images

  final ImagePicker _picker = ImagePicker();
  Future<void> pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      selectedImages.add(File(pickedFile.path));
    }
  }

  Future<List<String>> _uploadImagesToStorage() async {
    List<String> downloadUrls = [];
    for (File image in selectedImages) {
      String imageName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance.ref().child('uploads/$imageName');
      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      downloadUrls.add(downloadUrl);
    }
    return downloadUrls;
  }
  Future<void> addData() async {
    if (selectedImages.isEmpty) {
      Get.snackbar('Error', 'Please select at least one image', backgroundColor: Colors.red,snackPosition: SnackPosition.BOTTOM);
      return;
    }
    isLoading.value = true;
    List<String> imageUrls = await _uploadImagesToStorage();
    Map<String, dynamic> postData = {
      'posId': posId.value.text,
      'region': region.value.text,
      'mbuName': mbuName.value.text,
      'retailerName': retailerName.value.text,
      'retailerDetails': retailerDetails.value.text,
      'assetCamp': assetCamp.value.text,
      'franchiseId': franchiseId.value.text,
      'images': imageUrls,
    };
    try {
      await dataBase.push().set(postData);
      Get.snackbar("Success", "Data added successfully", backgroundColor: Colors.green);
    } catch (error) {
      Get.snackbar("Error", "Failed to add data", backgroundColor: Colors.red);
      log('Error posting data: $error');
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> updateData(String dataId) async {
    isLoading.value = true;
    List<String> imageUrls = await _uploadImagesToStorage();
    Map<String, dynamic> updatedData = {
      'posId': posId.value.text,
      'region': region.value.text,
      'mbuName': mbuName.value.text,
      'retailerName': retailerName.value.text,
      'retailerDetails': retailerDetails.value.text,
      'assetCamp': assetCamp.value.text,
      'franchiseId': franchiseId.value.text,
      'images': imageUrls,
    };
    try {
      await dataBase.child(dataId).update(updatedData);
      Get.snackbar("Success", "Data updated successfully", backgroundColor: Colors.green);
    } catch (error) {
      Get.snackbar("Error", "Failed to update data", backgroundColor: Colors.red);
      log('Error updating data: $error');
    } finally {
      isLoading.value = false;
    }
  }
}
