// import 'dart:io';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_practices/controllers/controller_posting_data.dart';
// import 'package:flutter_practices/screens/screen_show_database_data.dart';
// import 'package:flutter_practices/widgets/custom_button.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
//
// class ScreenAddInformationFirestore extends StatelessWidget {
//   final bool editData;
//   final String? dataId;
//
//   ScreenAddInformationFirestore({
//     required this.editData,
//     this.dataId,
//     super.key
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final DateTime firstDate = DateTime(1900);
//     final DateTime lastDate = DateTime.now();
//     ControllerFirebasePosting controllerFirebasePosting = Get.put(ControllerFirebasePosting());
//     final FirebaseDatabase database = FirebaseDatabase.instance;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(editData ? "Edit Information" : "Add Information"),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Obx(() {
//               return controllerFirebasePosting.selectedImage.value != null
//                   ? Image.file(
//                 File(controllerFirebasePosting.selectedImage.value!.path),
//                 height: 200.h,
//                 width: 200.h,
//                 fit: BoxFit.cover,
//               )
//                   : Container(
//                 height: 200.h,
//                 width: 200.h,
//                 color: Colors.grey[300],
//                 child: Icon(Icons.image, size: 100),
//               );
//             }),
//             SizedBox(height: 10.h),
//             ElevatedButton.icon(
//               onPressed: () {
//                 controllerFirebasePosting.showImagePicker(context);
//               },
//               icon: Icon(Icons.photo),
//               label: Text("Upload Image"),
//             ),
//             SizedBox(height: 10.h),
//             // Name field
//             TextFormField(
//               controller: controllerFirebasePosting.name.value,
//               style: TextStyle(color: Colors.black),
//               decoration: InputDecoration(
//                 prefixIcon: Icon(Icons.person),
//                 hintText: controllerFirebasePosting.name.value.text.isNotEmpty
//                     ? controllerFirebasePosting.name.value.text
//                     : "Name",
//               ),
//             ),
//             SizedBox(height: 10.h),
//             // Age field
//             TextFormField(
//               controller: controllerFirebasePosting.age.value,
//               style: TextStyle(color: Colors.black),
//               decoration: InputDecoration(
//                 prefixIcon: Icon(Icons.support_agent_rounded),
//                 hintText: "Age",
//               ),
//             ),
//             SizedBox(height: 10.h),
//             // Date of Birth field
//             TextFormField(
//               controller: controllerFirebasePosting.dateOfBirth.value,
//               readOnly: true,
//               style: TextStyle(color: Colors.black),
//               decoration: InputDecoration(
//                 prefixIcon: Icon(Icons.date_range),
//                 suffixIcon: IconButton(
//                   onPressed: () {
//                     showDatePicker(
//                       context: context,
//                       firstDate: firstDate,
//                       lastDate: lastDate,
//                       initialDate: DateTime.now(),
//                     ).then((DateTime? selectedDate) {
//                       if (selectedDate != null) {
//                         final DateFormat formatter = DateFormat('yyyy-MM-dd');
//                         final String formattedDate = formatter.format(selectedDate);
//                         controllerFirebasePosting.dateOfBirth.value.text = formattedDate;
//                       }
//                     });
//                   },
//                   icon: Icon(Icons.calendar_month),
//                 ),
//                 hintText: controllerFirebasePosting.dateOfBirth.value.text.isEmpty
//                     ? "Date of birth"
//                     : controllerFirebasePosting.dateOfBirth.value.text,
//               ),
//             ),
//             SizedBox(height: 10.h),
//             // Phone Number field
//             TextFormField(
//               controller: controllerFirebasePosting.phoneNo.value,
//               keyboardType: TextInputType.phone,
//               style: TextStyle(color: Colors.black),
//               decoration: InputDecoration(
//                 prefixIcon: Icon(Icons.phone),
//                 hintText: "Phone Number",
//               ),
//             ),
//             SizedBox(height: 10.h),
//             // Optional Email field
//             TextFormField(
//               controller: controllerFirebasePosting.optionalEmail.value,
//               style: TextStyle(color: Colors.black),
//               decoration: InputDecoration(
//                 prefixIcon: Icon(Icons.email),
//                 hintText: "Optional Email",
//               ),
//             ),
//             SizedBox(height: 10.h),
//             // Submit button
//             Obx(() {
//               return CustomButton(
//                 isLoading: controllerFirebasePosting.isLoading.value,
//                 buttonText: editData ? "Update" : "Submit",
//                 onTap: () {
//
//                 },
//               );
//             }).marginSymmetric(vertical: 8.h),
//           ],
//         ).marginSymmetric(horizontal: 10.w, vertical: 8.h),
//       ),
//     );
//   }
// }
