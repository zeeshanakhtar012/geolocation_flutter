// import 'dart:developer';
// import 'dart:io';
//
// import 'package:Jazz/controllers/controller_add_data.dart';
// import 'package:Jazz/screens/screen_live_location.dart';
// import 'package:Jazz/widgets/my_input_feild.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
//
// import '../constants/colors.dart';
// import '../widgets/custom_button.dart';
// import '../widgets/custom_image_picker_container.dart';
//
// class ScreenAddInformation extends StatefulWidget {
//   bool? isIntelligence;
//   bool? isVisit;
//   bool? isAssetDeploy;
//   bool? isTradeAssets;
//
//   @override
//   State<ScreenAddInformation> createState() => _ScreenAddInformationState();
//
//   ScreenAddInformation({
//     this.isIntelligence,
//     this.isVisit,
//     this.isAssetDeploy,
//     this.isTradeAssets,
//   });
// }
//
// class _ScreenAddInformationState extends State<ScreenAddInformation> {
//   ControllerAuthentication controller = Get.put(ControllerAuthentication());
//   late GoogleMapController mapController;
//   bool isPresent = false;
//
//   final LatLng _initialPosition = LatLng(37.7749, -122.4194); // San Francisco
//
//   void _onMapCreated(GoogleMapController controller) {
//     mapController = controller;
//   }
//
//   final List<String> assetsCamp = [
//     'Jazz',
//     'Zong',
//     'Telenor',
//     "Ufone",
//     "Others"
//   ];
//   String? _selectedItem;
//   List<String> imagePaths = [];
//
//   void _onSelected(String value) {
//     setState(() {
//       _selectedItem = value;
//       controller.selectedAsset.value;
//     });
//   }
//
//   void _onImagePicked(String imagePath) {
//     setState(() {
//       imagePaths.add(imagePath);
//       controller.images.length > 0 ? controller.images.add(imagePath) : null;
//     });
//   }
//
//   final List<String> retailerDetails = [
//     'Facia',
//     'Wali point',
//     'In store branding',
//     "OOH",
//     "Others(Specify)",
//     "BTL activity",
//     "Dedicated shop"
//   ];
//   final List<String> title = [
//     'Jazz Trade Intelligence',
//     'Visit Log',
//     'Asset Deployment',
//     "Trade Asset",
//   ];
//
//   String _getTitle() {
//     if (widget.isIntelligence == true) {
//       return title[0];
//     } else if (widget.isVisit == true) {
//       return title[1];
//     } else if (widget.isAssetDeploy == true) {
//       return title[2];
//     } else if (widget.isTradeAssets == true) {
//       return title[3];
//     } else {
//       return "Add Data";
//     }
//   }
//
//   String? _selectedDetails;
//
//   void _onSelectedRetailer(String value) {
//     setState(() {
//       _selectedDetails = value;
//       controller.selectedRetailerDetail.value;
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     controller.saveData(controller.lat.value, controller.lng.value);
//   }
//
//   Future<void> _initializeMap() async {
//     // Initialization logic here
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//             onPressed: () {
//               Get.back();
//             },
//             icon: Icon(
//               Icons.arrow_back_ios,
//               color: Colors.white,
//             )),
//         title: Text(
//           _getTitle(),
//           style: TextStyle(
//               color: Colors.black,
//               fontSize: 16.sp,
//               fontWeight: FontWeight.w600),
//         ),
//         actions: [IconButton(onPressed: (){
//           Get.to(ScreenAddInformation());
//         }, icon: Icon(Icons.next_plan, color: Colors.red,))],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Location:",
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 16.sp,
//                 fontWeight: FontWeight.w500,
//               ),
//             ).marginOnly(
//               bottom: 5.h,
//             ),
//             SizedBox(height: 10.h),
//             //asset type
//             if (widget.isIntelligence == true)
//               Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "Type of Asset",
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ).marginOnly(
//                     bottom: 5.h,
//                   ),
//                   MyInputField(
//                     controller: controller.selectedAsset.value,
//                     padding: EdgeInsets.symmetric(
//                       vertical: 8.h,
//                       horizontal: 8.w,
//                     ),
//                     readOnly: true,
//                     textStyle: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w500,
//                     ),
//                     hint: _selectedItem ?? "Type Asset",
//                     suffix: PopupMenuButton<String>(
//                       icon: Icon(
//                         Icons.keyboard_arrow_down_sharp,
//                         color: Colors.white,
//                       ),
//                       onSelected: _onSelected,
//                       itemBuilder: (BuildContext context) {
//                         return assetsCamp.map((String choice) {
//                           return PopupMenuItem<String>(
//                             value: choice,
//                             child: Text(choice),
//                           );
//                         }).toList();
//                       },
//                     ),
//                   ),
//                   SizedBox(height: 10.h),
//                   // retailer details pop up
//                   Text(
//                     "Asset Camping",
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ).marginOnly(
//                     bottom: 5.h,
//                   ),
//                   MyInputField(
//                     controller: controller.assetCamp.value,
//                     padding: EdgeInsets.symmetric(
//                       vertical: 8.h,
//                       horizontal: 8.w,
//                     ),
//                     readOnly: true,
//                     textStyle: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w500,
//                     ),
//                     hint: _selectedDetails ?? "Asset Camping",
//                     suffix: PopupMenuButton<String>(
//                       icon: Icon(
//                         Icons.keyboard_arrow_down_sharp,
//                         color: Colors.white,
//                       ),
//                       onSelected: _onSelectedRetailer,
//                       itemBuilder: (BuildContext context) {
//                         return retailerDetails.map((String choice) {
//                           return PopupMenuItem<String>(
//                             value: choice,
//                             child: Text(choice),
//                           );
//                         }).toList();
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             SizedBox(height: 10.h),
//             //visit log//////////////////////////
//             if (widget.isVisit == true)
//               Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "POSID",
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ).marginOnly(
//                     bottom: 5.h,
//                   ),
//                   MyInputField(
//                     controller: controller.posId.value,
//                     padding: EdgeInsets.symmetric(
//                       vertical: 8.h,
//                       horizontal: 8.w,
//                     ),
//                     textStyle: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w500,
//                     ),
//                     hint: "POSID",
//                   ),
//                   SizedBox(height: 10.h),
//                   Text(
//                     "Retailer Name",
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ).marginOnly(
//                     bottom: 5.h,
//                   ),
//                   MyInputField(
//                     controller: controller.retailerName.value,
//                     padding: EdgeInsets.symmetric(
//                       vertical: 8.h,
//                       horizontal: 8.w,
//                     ),
//                     textStyle: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w500,
//                     ),
//                     hint: "Retailer Name",
//                   ),
//                   SizedBox(height: 10.h),
//                   Text(
//                     "Retailer Address",
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ).marginOnly(
//                     bottom: 5.h,
//                   ),
//                   MyInputField(
//                     controller: controller.retailerAddress.value,
//                     padding: EdgeInsets.symmetric(
//                       vertical: 8.h,
//                       horizontal: 8.w,
//                     ),
//                     textStyle: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w500,
//                     ),
//                     hint: "Retailer Address",
//                   ),
//                   SizedBox(height: 10.h),
//                 ],
//               ),
//             SizedBox(height: 10.h),
//             if (widget.isAssetDeploy == true)
//               Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "POSID",
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ).marginOnly(
//                     bottom: 5.h,
//                   ),
//                   MyInputField(
//                     controller: controller.posId.value,
//                     padding: EdgeInsets.symmetric(
//                       vertical: 8.h,
//                       horizontal: 8.w,
//                     ),
//                     textStyle: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w500,
//                     ),
//                     hint: "POSID",
//                   ),
//                   Text(
//                     "Type of Asset",
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ).marginOnly(
//                     bottom: 5.h,
//                     top: 5.h,
//                   ),
//                   MyInputField(
//                     controller: controller.selectedAsset.value,
//                     padding: EdgeInsets.symmetric(
//                       vertical: 8.h,
//                       horizontal: 8.w,
//                     ),
//                     readOnly: true,
//                     textStyle: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w500,
//                     ),
//                     hint: _selectedItem ?? "Type Asset",
//                     suffix: PopupMenuButton<String>(
//                       icon: Icon(
//                         Icons.keyboard_arrow_down_sharp,
//                         color: Colors.white,
//                       ),
//                       onSelected: _onSelected,
//                       itemBuilder: (BuildContext context) {
//                         return assetsCamp.map((String choice) {
//                           return PopupMenuItem<String>(
//                             value: choice,
//                             child: Text(choice),
//                           );
//                         }).toList();
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             if (widget.isTradeAssets == true)
//               Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "POSID",
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ).marginOnly(
//                     bottom: 5.h,
//                   ),
//                   MyInputField(
//                     controller: controller.posId.value,
//                     padding: EdgeInsets.symmetric(
//                       vertical: 8.h,
//                       horizontal: 8.w,
//                     ),
//                     textStyle: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w500,
//                     ),
//                     hint: "POSID",
//                   ),
//                   Text(
//                     "Type of Asset",
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ).marginOnly(
//                     bottom: 5.h,
//                     top: 5.h,
//                   ),
//                   MyInputField(
//                     controller: controller.selectedAsset.value,
//                     padding: EdgeInsets.symmetric(
//                       vertical: 8.h,
//                       horizontal: 8.w,
//                     ),
//                     readOnly: true,
//                     textStyle: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w500,
//                     ),
//                     hint: _selectedItem ?? "Type Asset",
//                     suffix: PopupMenuButton<String>(
//                       icon: Icon(
//                         Icons.keyboard_arrow_down_sharp,
//                         color: Colors.white,
//                       ),
//                       onSelected: _onSelected,
//                       itemBuilder: (BuildContext context) {
//                         return assetsCamp.map((String choice) {
//                           return PopupMenuItem<String>(
//                             value: choice,
//                             child: Text(choice),
//                           );
//                         }).toList();
//                       },
//                     ),
//                   ),
//                   SizedBox(height: 10.h),
//                   Text(
//                     "Retailer Name",
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ).marginOnly(
//                     bottom: 5.h,
//                   ),
//                   MyInputField(
//                     controller: controller.retailerName.value,
//                     padding: EdgeInsets.symmetric(
//                       vertical: 8.h,
//                       horizontal: 8.w,
//                     ),
//                     textStyle: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w500,
//                     ),
//                     hint: "Retailer Name",
//                   ),
//                   SizedBox(height: 10.h),
//                   Text(
//                     "Retailer Address",
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ).marginOnly(
//                     bottom: 5.h,
//                   ),
//                   MyInputField(
//                     controller: controller.retailerAddress.value,
//                     padding: EdgeInsets.symmetric(
//                       vertical: 8.h,
//                       horizontal: 8.w,
//                     ),
//                     textStyle: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w500,
//                     ),
//                     hint: "Retailer Address",
//                   ),
//                 ],
//               ),
//             // if (widget.isTradeAssets == true &&
//             //     widget.isVisit == true &&
//             //     widget.isAssetDeploy == true)
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("Mark Attendance",
//                         style: TextStyle(
//                           color: Colors.green,
//                           fontWeight: FontWeight.w700,
//                           fontSize: 17.sp,
//                         )),
//                     Text("Must Enable",
//                         style: TextStyle(
//                           color: Colors.red,
//                           fontWeight: FontWeight.w700,
//                           fontSize: 12.sp,
//                         )),
//                   ],
//                 ),
//                 Switch(
//                   value: controller.isPresent.value,
//                   onChanged: (bool value) {
//                     setState(() {
//                       controller.markAttendance(value);
//                     });
//                   },
//                   activeColor: Colors.green,
//                   inactiveThumbColor: Colors.red,
//                   inactiveTrackColor: Colors.red[200],
//                 ),
//               ],
//             ),
//             Text(
//               "Upload Pics",
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 16.sp,
//                 fontWeight: FontWeight.w500,
//               ),
//             ).marginOnly(
//               bottom: 5.h,
//             ),
//             Row(
//               children: [
//                 CustomImagePickerContainer(
//                   onImagePicked: _onImagePicked,
//                 ),
//                 SizedBox(
//                   width: 10.w,
//                 ),
//                 CustomImagePickerContainer(
//                   onImagePicked: _onImagePicked,
//                 ),
//                 SizedBox(
//                   width: 10.w,
//                 ),
//                 CustomImagePickerContainer(
//                   onImagePicked: _onImagePicked,
//                 ),
//               ],
//             ).marginOnly(
//               top: 10.h,
//             ),
//             SizedBox(
//               height: 10.w,
//             ),
//             Row(
//               children: [
//                 CustomImagePickerContainer(
//                   onImagePicked: _onImagePicked,
//                 ),
//                 SizedBox(
//                   width: 10.w,
//                 ),
//                 CustomImagePickerContainer(
//                   onImagePicked: _onImagePicked,
//                 ),
//                 SizedBox(
//                   width: 10.w,
//                 ),
//                 CustomImagePickerContainer(
//                   onImagePicked: _onImagePicked,
//                 ),
//               ],
//             ),
//             SizedBox(height: 10.h),
//             Obx(() {
//               return CustomButton(
//                 isLoading: controller.isLoading.value,
//                 buttonColor: AppColors.buttonColor,
//                 buttonText: "Upload Data",
//                 onTap: () async {
//                   await controller.getLocation();
//                   for (String imagePath in controller.images) {
//                     File imageFile = File(imagePath);
//                     String downloadUrl = await controller.uploadImageToStorage(imageFile);
//                     log('Image uploaded: $downloadUrl');
//                   }
//                   await controller.saveData(controller.lat.value, controller.lng.value);
//                 },
//               );
//             }).marginSymmetric(vertical: 8.h),
//           ],
//         ).marginSymmetric(horizontal: 10.w, vertical: 8.h),
//       ),
//     );
//   }
// }
