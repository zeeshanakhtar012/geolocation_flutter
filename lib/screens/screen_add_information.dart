import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_practices/constants/colors.dart';
import 'package:flutter_practices/controllers/controller_posting_data.dart';
import 'package:flutter_practices/screens/screen_show_database_data.dart';
import 'package:flutter_practices/widgets/custom_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ScreenAddInformation extends StatelessWidget {
  final bool editData;
  final String? dataId;

  ScreenAddInformation({
    required this.editData,
    this.dataId,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).width;
    final width = MediaQuery.sizeOf(context).height;
    final DateTime firstDate = DateTime(1900);
    final DateTime lastDate = DateTime.now();
    ControllerFirebasePosting controllerFirebasePosting = Get.put(ControllerFirebasePosting());
    final FirebaseDatabase database = FirebaseDatabase.instance;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Get.back();
        }, icon: Icon(Icons.arrow_back_ios, color: Colors.white,)),
        title: Text(editData ? "Update Information" : "Add Information",
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600
        ),
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
              Obx(() {
                return controllerFirebasePosting.selectedImage.value != null
                    ? Image.file(
                  File(controllerFirebasePosting.selectedImage.value!.path),
                  height: 200.h,
                  width: 200.h,
                  fit: BoxFit.cover,
                )
                    : Container(
                  height: 200.h,
                  width: 200.h,
                  color: Colors.grey[300],
                  child: Icon(Icons.image, size: 100),
                );
              }),
              SizedBox(height: 10.h),
              ElevatedButton.icon(
                onPressed: () {
                  controllerFirebasePosting.showImagePicker(context);
                },
                icon: Icon(Icons.photo),
                label: Text("Upload Image"),
              ),
              SizedBox(height: 10.h),
              // Name field
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
                    keyboardType: TextInputType.name,
                    controller: controllerFirebasePosting.name.value,
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
                      contentPadding: EdgeInsets.symmetric(vertical: 15.h), // Adjust this as needed
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                      hintText: controllerFirebasePosting.name.value.text.isNotEmpty
                          ? controllerFirebasePosting.name.value.text
                          : "Name",
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              // Age field
              Container(
                alignment: Alignment.center,
                height: 50.h,
                width: width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: Color(0xFF190733),
                ),
                child: TextFormField(
                  keyboardType: TextInputType.phone,
                  controller: controllerFirebasePosting.age.value,
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
                    contentPadding: EdgeInsets.symmetric(vertical: 15.h), // Adjust this as needed
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                    hintText: controllerFirebasePosting.name.value.text.isNotEmpty
                        ? controllerFirebasePosting.name.value.text
                        : "Age",
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              // Date of Birth field
              Container(
                alignment: Alignment.center,
                height: 50.h,
                width: width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: Color(0xFF190733),
                ),
                child: TextFormField(
                  controller: controllerFirebasePosting.dateOfBirth.value,
                  readOnly: true,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 15.h), // Adjust this as needed
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                    prefixIcon: Icon(Icons.date_range, color: Colors.white,),
                    suffixIcon: IconButton(
                      onPressed: () {
                        showDatePicker(
                          context: context,
                          firstDate: firstDate,
                          lastDate: lastDate,
                          initialDate: DateTime.now(),
                        ).then((DateTime? selectedDate) {
                          if (selectedDate != null) {
                            final DateFormat formatter = DateFormat('yyyy-MM-dd');
                            final String formattedDate = formatter.format(selectedDate);
                            controllerFirebasePosting.dateOfBirth.value.text = formattedDate;
                          }
                        });
                      },
                      icon: Icon(Icons.calendar_month, color: Colors.white,),
                    ),
                    hintText: controllerFirebasePosting.dateOfBirth.value.text.isEmpty
                        ? "Date of birth"
                        : controllerFirebasePosting.dateOfBirth.value.text,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              // Phone Number field
              Container(
                alignment: Alignment.center,
                height: 50.h,
                width: width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: Color(0xFF190733),
                ),
                child: TextFormField(
                  controller: controllerFirebasePosting.phoneNo.value,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 15.h), // Adjust this as needed
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                    prefixIcon: Icon(Icons.phone, color: Colors.white,),
                    hintText: "Phone Number",
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              // Optional Email field
              Container(
                alignment: Alignment.center,
                height: 50.h,
                width: width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: Color(0xFF190733),
                ),
                child: TextFormField(
                  controller: controllerFirebasePosting.optionalEmail.value,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 15.h), // Adjust this as needed
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                    prefixIcon: Icon(Icons.email, color: Colors.white,),
                    hintText: "Optional Email",
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              // Submit button
              Obx(() {
                return CustomButton(
                  buttonColor: AppColors.appColor,
                  isLoading: controllerFirebasePosting.isLoading.value,
                  buttonText: editData ? "Update" : "Submit",
                  onTap: () {
                    if (editData && dataId != null) {
                      controllerFirebasePosting.updateData(dataId!);
                    } else {
                      controllerFirebasePosting.addData();
                    }
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
