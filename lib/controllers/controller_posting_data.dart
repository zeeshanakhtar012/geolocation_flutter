import 'dart:developer';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_practices/utils/firebase_utils.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/firebase_utils.dart';
import '../screens/screen_show_database_data.dart';

class ControllerFirebasePosting extends GetxController {
  final dataBase = FirebaseDatabase.instance.ref('post');

  var name = TextEditingController().obs;
  var age = TextEditingController().obs;
  var dateOfBirth = TextEditingController().obs;
  var phoneNo = TextEditingController().obs;
  var optionalEmail = TextEditingController().obs;
  var search = TextEditingController().obs;
  var isLoading = false.obs;
  var selectedImage = Rx<File?>(null);

  void showImagePicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text('Gallery'),
                  onTap: () {
                    pickImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_camera),
                  title: Text('Camera'),
                  onTap: () {
                    pickImage(ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }

  Future<void> pickImage(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      selectedImage.value = File(image.path);
    }
  }

  Future<void> addData() async {
    if (selectedImage.value != null) {
      try {
        isLoading.value = true;

        // Upload the image and get the URL
        String? imageUrl = await FirebaseUtils.uploadImage(
          selectedImage.value!.path,
          'posts/${DateTime.now().millisecondsSinceEpoch}',
        );

        if (imageUrl == null || imageUrl.isEmpty) {
          FirebaseUtils.showError("Image upload failed. Please try again.");
          return;
        }

        String newPostKey = dataBase.push().key ?? '';

        // Prepare data to upload
        final data = {
          'id': newPostKey,
          'name': name.value.text,
          'age': age.value.text,
          'dateOfBirth': dateOfBirth.value.text,
          'phoneNo': phoneNo.value.text,
          'optionalEmail': optionalEmail.value.text,
          'selectedImage': imageUrl,  // Store the URL
        };

        log("Data to be uploaded: $data");
        await dataBase.child(newPostKey).set(data);

        FirebaseUtils.showSuccess("Data Uploaded Successfully");
        Get.back();
        name.value.clear();
        age.value.clear();
        dateOfBirth.value.clear();
        phoneNo.value.clear();
        optionalEmail.value.clear();
        selectedImage.value = null;

      } catch (e) {
        FirebaseUtils.showError("Error occurred while uploading data: $e");
        log("Error uploading data: $e"); // Log the error
      } finally {
        isLoading.value = false;
      }
    } else {
      FirebaseUtils.showError("No image selected. Please select an image.");
    }
  }


  Future<void> updateData(String id) async {
    try {
      await dataBase.child(id).update({
        'name': name.value.text,
        'age': age.value.text,
        'dateOfBirth': dateOfBirth.value.text,
        'phoneNo': phoneNo.value.text,
        'optionalEmail': optionalEmail.value.text,
        'selectedImage': selectedImage.value?.path,
      });
      FirebaseUtils.showSuccess("Data Updated Successfully");
      Get.back();
    } catch (e) {
      FirebaseUtils.showError("Error occurred while updating data: $e");
    }
  }

  Future<void> deleteData(String id) async {
    try {
      await dataBase.child(id).remove();
      FirebaseUtils.showSuccess("Data Deleted Successfully");
    } catch (e) {
      FirebaseUtils.showError("Error occurred while deleting data: $e");
    }
  }
}
