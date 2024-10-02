import 'dart:developer';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_practices/constants/colors.dart';
import 'package:flutter_practices/controllers/controller_posting_data.dart';
import 'package:flutter_practices/screens/screen_show_database_data.dart';
import 'package:flutter_practices/widgets/custom_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../widgets/custom_image_picker_container.dart';

class ScreenAddInformation extends StatefulWidget {
  final bool editData;
  final String? dataId;

  ScreenAddInformation({required this.editData, this.dataId, super.key});

  @override
  State<ScreenAddInformation> createState() => _ScreenAddInformationState();
}

class _ScreenAddInformationState extends State<ScreenAddInformation> {
  late GoogleMapController mapController;

  // Set the initial position of the map
  final LatLng _initialPosition = LatLng(37.7749, -122.4194); // San Francisco

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  ControllerFirebasePosting controllerFirebasePosting =
      Get.put(ControllerFirebasePosting());
  final List<String> assetsCamp = [
    'Jazz',
    'Zong',
    'Telenor',
    "Ufone",
    "Others"
  ];
  String? _selectedItem;
  List<String> imagePaths = [];

  void _onSelected(String value) {
    setState(() {
      _selectedItem = value;
      controllerFirebasePosting.assetCamp.value;
    });
  }

  void _onImagePicked(String imagePath) {
    setState(() {
      imagePaths.add(imagePath); // Add image paths to the list for display
      controllerFirebasePosting.selectedImages
          .add(File(imagePath)); // Add the image file to the controller
    });
  }

  final List<String> retailerDetails = [
    'Facia',
    'Wali point',
    'In store branding',
    "OOH",
    "Others(Specify)",
    "BTL activity",
    "Dedicated shop"
  ];
  String? _selectedDetails;

  void _onSelectedRetailer(String value) {
    setState(() {
      _selectedDetails = value;
      controllerFirebasePosting.retailerDetails.value;
    });
  }

  @override
  void initState() {
    super.initState();
    controllerFirebasePosting.addData();
  }

  Future<void> _initializeMap() async {
    // Initialization logic here
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).width;
    final width = MediaQuery.sizeOf(context).height;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        title: Text(
          widget.editData ? "Update Information" : "Add Information",
          style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600),
        ),
      ),
      body: Container(
        height: height.sh,
        width: width.sw,
        decoration: BoxDecoration(
          gradient: AppColors.appBackgroundColor,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  height: 299.h,
                  width: 375.w,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: Center(
                      child: Text(
                    "Google Map Live",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ))),
              SizedBox(height: 10.h),
              Container(
                alignment: Alignment.center,
                height: 50.h,
                width: width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: Color(0xFF190733),
                ),
                child: Center(
                  child: TextFormField(
                    controller: controllerFirebasePosting.posId.value,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 30.sp,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 15.h),
                      // Adjust this as needed
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                      hintText:
                          controllerFirebasePosting.posId.value.text.isNotEmpty
                              ? controllerFirebasePosting.posId.value.text
                              : "POSID",
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                alignment: Alignment.center,
                height: 50.h,
                width: width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: Color(0xFF190733),
                ),
                child: TextFormField(
                  readOnly: true,
                  controller: controllerFirebasePosting.assetCamp.value,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.grading,
                      color: Colors.white,
                      size: 30.sp,
                    ),
                    suffixIcon: PopupMenuButton<String>(
                      icon: Icon(
                        Icons.keyboard_arrow_down_sharp,
                        color: Colors.white,
                      ),
                      onSelected: _onSelected,
                      itemBuilder: (BuildContext context) {
                        return assetsCamp.map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice),
                          );
                        }).toList();
                      },
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 15.h),
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                    hintText: _selectedItem ?? "Asset Camping",
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                alignment: Alignment.center,
                height: 50.h,
                width: width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: Color(0xFF190733),
                ),
                child: TextFormField(
                  controller: controllerFirebasePosting.retailerDetails.value,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                  decoration: InputDecoration(
                    suffixIcon: PopupMenuButton<String>(
                      icon: Icon(
                        Icons.keyboard_arrow_down_sharp,
                        color: Colors.white,
                      ),
                      onSelected: _onSelectedRetailer,
                      itemBuilder: (BuildContext context) {
                        return retailerDetails.map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice),
                          );
                        }).toList();
                      },
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 15.h),
                    // Adjust this as needed
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                    prefixIcon: Icon(
                      Icons.details,
                      color: Colors.white,
                    ),
                    hintText: _selectedDetails ?? "Retailer Details",
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                alignment: Alignment.center,
                height: 50.h,
                width: width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: Color(0xFF190733),
                ),
                child: TextFormField(
                  controller: controllerFirebasePosting.retailerName.value,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 15.h),
                    // Adjust this as needed
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                    prefixIcon: Icon(
                      Icons.drive_file_rename_outline,
                      color: Colors.white,
                    ),
                    hintText: "Retailer Name",
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                alignment: Alignment.center,
                height: 50.h,
                width: width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: Color(0xFF190733),
                ),
                child: TextFormField(
                  controller: controllerFirebasePosting.posId.value,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 15.h),
                    // Adjust this as needed
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                    prefixIcon: Icon(
                      Icons.post_add,
                      color: Colors.white,
                    ),
                    hintText: "POSID",
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                alignment: Alignment.center,
                height: 50.h,
                width: width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: Color(0xFF190733),
                ),
                child: TextFormField(
                  controller: controllerFirebasePosting.franchiseId.value,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 15.h),
                    // Adjust this as needed
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                    prefixIcon: Icon(
                      Icons.insert_drive_file_outlined,
                      color: Colors.white,
                    ),
                    hintText: "Franchise Id",
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  CustomImagePickerContainer(
                    onImagePicked: _onImagePicked,
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  CustomImagePickerContainer(
                    onImagePicked: _onImagePicked,
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  CustomImagePickerContainer(
                    onImagePicked: _onImagePicked,
                  ),
                ],
              ),
              SizedBox(
                height: 10.w,
              ),
              Row(
                children: [
                  CustomImagePickerContainer(
                    onImagePicked: _onImagePicked,
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  CustomImagePickerContainer(
                    onImagePicked: _onImagePicked,
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  CustomImagePickerContainer(
                    onImagePicked: _onImagePicked,
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Obx(() {
                return CustomButton(
                  buttonColor: AppColors.buttonColor,
                  isLoading: controllerFirebasePosting.isLoading.value,
                  buttonText: widget.editData ? "Update" : "Submit",
                  onTap: () {
                    log("Image address ${controllerFirebasePosting.selectedImages.length}");
                    controllerFirebasePosting.addData();
                    // if (widget.editData && widget.dataId != null) {
                    //   controllerFirebasePosting.updateData(widget.dataId!);
                    // } else {
                    //
                    // }
                  },
                );
              }).marginSymmetric(vertical: 8.h),
            ],
          ).marginSymmetric(horizontal: 10.w, vertical: 8.h),
        ),
      ),
    );
  }
}
