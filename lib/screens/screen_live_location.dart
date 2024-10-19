// import 'dart:async';
// import 'dart:developer';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import '../../widgets/my_input_feild.dart';
// import '../constants/colors.dart';
// import '../controllers/controller_add_data.dart';
// import '../utils/location_utils.dart';
// import '../widgets/custom_button.dart';
// import '../widgets/custom_image_picker_container.dart';
//
// class ScreenAddInformation extends StatelessWidget {
//   bool? isIntelligence;
//   bool? isVisit;
//   bool? isAssetDeploy;
//   bool? isTradeAssets;
//
//   ScreenAddInformation({
//     Key? key,
//     this.isIntelligence,
//     this.isVisit,
//     this.isAssetDeploy,
//     this.isTradeAssets,
//   }) : super(key: key);
//
//   Completer<GoogleMapController> _controller = Completer();
//   ControllerAuthentication controller = Get.put(ControllerAuthentication());
//   final List<String> title = [
//     'Jazz Trade Intelligence',
//     'Visit Log',
//     'Asset Deployment',
//     "Trade Asset",
//   ];
//
//   String _getTitle() {
//     if (isIntelligence == true) {
//       return title[0];
//     } else if (isVisit == true) {
//       return title[1];
//     } else if (isAssetDeploy == true) {
//       return title[2];
//     } else if (isTradeAssets == true) {
//       return title[3];
//     } else {
//       return "Add Data";
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
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
//         // actions: [
//         //   TextButton(onPressed: (){
//         //     Get.to(ScreenAddNumberWhiteList());
//         //   }, child: Text("Add Number",style: TextStyle(color: Colors.green),))
//         // ],
//       ),
//       body: FutureBuilder<bool>(
//           future: checkPermissionStatus(),
//           builder: (context, snapshot) {
//             return FutureBuilder<Position>(
//                 future: Geolocator.getCurrentPosition(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return Center(
//                         child: CircularProgressIndicator(
//                             // color: const Color(0xFF65B901),
//                             // strokeWidth: 3,
//                             ));
//                   }
//                   var position = snapshot.data;
//                   return FutureBuilder<Placemark?>(
//                       future: getAddressFromCurrentLocation(),
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState ==
//                             ConnectionState.waiting) {
//                           return Center(
//                               child: CircularProgressIndicator(
//                                   // color: const Color(0xFF65B901),
//                                   // strokeWidth: 3,
//                                   ));
//                         }
//                         var address = snapshot.data;
//                         controller.address.value="${address!.subLocality ??""} ${address!.country ??""}";
//                         log("Current address == ${controller.address.value}");
//                         return Obx(() {
//                           return SingleChildScrollView(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               children: <Widget>[
//                                 Container(
//                                   padding: EdgeInsets.only(left: 10.w),
//                                   height: 50.h,
//                                   width: Get.width,
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(8.r),
//                                     color: Color(0xFF190733),
//                                   ),
//                                   child: Center(
//                                     child: TextFormField(
//                                       controller: controller.phoneNo.value,
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.w600,
//                                         fontSize: 14.sp,
//                                       ),
//                                       keyboardType: TextInputType.phone,
//                                       decoration: InputDecoration(
//                                         border: InputBorder.none,
//                                         hintStyle: TextStyle(
//                                           color: Colors.white,
//                                           fontWeight: FontWeight.w600,
//                                           fontSize: 14.sp,
//                                         ),
//                                         hintText: "+92 300 1234567",
//                                       ),
//                                     ),
//                                   ),
//                                 ).marginOnly(
//                                   bottom: 10.h,
//                                 ),
//                                 SizedBox(
//                                   height: 350.h,
//                                   width: 350.w,
//                                   child: ClipRRect(
//                                     borderRadius: BorderRadius.circular(20.r),
//                                     child: StatefulBuilder(
//                                       builder: (BuildContext context,
//                                           void Function(void Function())
//                                               setState) {
//                                         return GoogleMap(
//                                           mapType: MapType.hybrid,
//                                           initialCameraPosition: CameraPosition(
//                                             target: LatLng(position!.latitude,
//                                                 position.longitude),
//                                             zoom: 14.4746,
//                                           ),
//                                           markers: {
//                                             Marker(
//                                               markerId: const MarkerId(
//                                                   'currentLocation'),
//                                               position: LatLng(
//                                                   position.latitude,
//                                                   position.longitude),
//                                             ),
//                                           },
//                                           onMapCreated:
//                                               (GoogleMapController controller) {
//                                             _controller.complete(controller);
//                                           },
//                                           gestureRecognizers: {
//                                             Factory<OneSequenceGestureRecognizer>(
//                                                   () => EagerGestureRecognizer(),
//                                             ),
//                                           },
//                                         );
//                                       },
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   height: 10.h,
//                                 ),
//                                 Column(
//                                   children: [
//                                     //asset type
//                                     if (isIntelligence == true)
//                                       Column(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.start,
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             "Type of Asset",
//                                             style: TextStyle(
//                                               color: Colors.black,
//                                               fontSize: 16.sp,
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                           ).marginOnly(
//                                             bottom: 5.h,
//                                           ),
//                                           Obx(() {
//                                             return MyInputField(
//                                               controller: controller
//                                                   .selectedAsset.value,
//                                               padding: EdgeInsets.symmetric(
//                                                 vertical: 8.h,
//                                                 horizontal: 8.w,
//                                               ),
//                                               readOnly: true,
//                                               textStyle: TextStyle(
//                                                 color: Colors.white,
//                                                 fontSize: 16.sp,
//                                                 fontWeight: FontWeight.w500,
//                                               ),
//                                               hint: controller.selectedItem ??
//                                                   "Type Asset",
//                                               suffix: PopupMenuButton<String>(
//                                                 icon: Icon(
//                                                   Icons
//                                                       .keyboard_arrow_down_sharp,
//                                                   color: Colors.white,
//                                                 ),
//                                                 onSelected:
//                                                     controller.onSelected,
//                                                 itemBuilder:
//                                                     (BuildContext context) {
//                                                   return controller.assetsCamp
//                                                       .map((String choice) {
//                                                     return PopupMenuItem<
//                                                         String>(
//                                                       value: choice,
//                                                       child: Text(choice),
//                                                     );
//                                                   }).toList();
//                                                 },
//                                               ),
//                                             );
//                                           }),
//                                           SizedBox(height: 10.h),
//                                           // retailer details pop up
//                                           Text(
//                                             "Asset Camping",
//                                             style: TextStyle(
//                                               color: Colors.black,
//                                               fontSize: 16.sp,
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                           ).marginOnly(
//                                             bottom: 5.h,
//                                           ),
//                                           MyInputField(
//                                             controller: controller
//                                                 .selectedRetailerDetail.value,
//                                             // Use the correct controller
//                                             padding: EdgeInsets.symmetric(
//                                               vertical: 8.h,
//                                               horizontal: 8.w,
//                                             ),
//                                             readOnly: true,
//                                             textStyle: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 16.sp,
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                             hint: controller.selectedDetails !=
//                                                     null
//                                                 ? controller
//                                                     .selectedDetails // Show the selected retailer detail
//                                                 : "Asset Camping",
//                                             suffix: PopupMenuButton<String>(
//                                               icon: Icon(
//                                                 Icons.keyboard_arrow_down_sharp,
//                                                 color: Colors.white,
//                                               ),
//                                               onSelected:
//                                                   controller.onSelectedRetailer,
//                                               // Trigger the retailer selection
//                                               itemBuilder:
//                                                   (BuildContext context) {
//                                                 return controller
//                                                     .retailerDetails
//                                                     .map((String choice) {
//                                                   return PopupMenuItem<String>(
//                                                     value: choice,
//                                                     child: Text(choice),
//                                                   );
//                                                 }).toList();
//                                               },
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     SizedBox(height: 10.h),
//                                     //visit log//////////////////////////
//                                     if (isVisit == true)
//                                       Column(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.start,
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             "POSID",
//                                             style: TextStyle(
//                                               color: Colors.black,
//                                               fontSize: 16.sp,
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                           ).marginOnly(
//                                             bottom: 5.h,
//                                           ),
//                                           MyInputField(
//                                             controller: controller.posId.value,
//                                             padding: EdgeInsets.symmetric(
//                                               vertical: 8.h,
//                                               horizontal: 8.w,
//                                             ),
//                                             textStyle: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 16.sp,
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                             hint: "POSID",
//                                           ),
//                                           SizedBox(height: 10.h),
//                                           Text(
//                                             "Retailer Name",
//                                             style: TextStyle(
//                                               color: Colors.black,
//                                               fontSize: 16.sp,
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                           ).marginOnly(
//                                             bottom: 5.h,
//                                           ),
//                                           MyInputField(
//                                             controller:
//                                                 controller.retailerName.value,
//                                             padding: EdgeInsets.symmetric(
//                                               vertical: 8.h,
//                                               horizontal: 8.w,
//                                             ),
//                                             textStyle: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 16.sp,
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                             hint: "Retailer Name",
//                                           ),
//                                           SizedBox(height: 10.h),
//                                           Text(
//                                             "Retailer Address",
//                                             style: TextStyle(
//                                               color: Colors.black,
//                                               fontSize: 16.sp,
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                           ).marginOnly(
//                                             bottom: 5.h,
//                                           ),
//                                           MyInputField(
//                                             controller: controller
//                                                 .retailerAddress.value,
//                                             padding: EdgeInsets.symmetric(
//                                               vertical: 8.h,
//                                               horizontal: 8.w,
//                                             ),
//                                             textStyle: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 16.sp,
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                             hint: "Retailer Address",
//                                           ),
//                                           SizedBox(height: 10.h),
//                                         ],
//                                       ),
//                                     SizedBox(height: 10.h),
//                                     if (isAssetDeploy == true)
//                                       Column(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.start,
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             "POSID",
//                                             style: TextStyle(
//                                               color: Colors.black,
//                                               fontSize: 16.sp,
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                           ).marginOnly(
//                                             bottom: 5.h,
//                                           ),
//                                           MyInputField(
//                                             controller: controller.posId.value,
//                                             padding: EdgeInsets.symmetric(
//                                               vertical: 8.h,
//                                               horizontal: 8.w,
//                                             ),
//                                             textStyle: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 16.sp,
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                             hint: "POSID",
//                                           ),
//                                           Text(
//                                             "Type of Asset",
//                                             style: TextStyle(
//                                               color: Colors.black,
//                                               fontSize: 16.sp,
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                           ).marginOnly(
//                                             bottom: 5.h,
//                                             top: 5.h,
//                                           ),
//                                           MyInputField(
//                                             controller:
//                                                 controller.selectedAsset.value,
//                                             padding: EdgeInsets.symmetric(
//                                               vertical: 8.h,
//                                               horizontal: 8.w,
//                                             ),
//                                             readOnly: true,
//                                             textStyle: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 16.sp,
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                             hint: controller.selectedItem ??
//                                                 "Type Asset",
//                                             suffix: PopupMenuButton<String>(
//                                               icon: Icon(
//                                                 Icons.keyboard_arrow_down_sharp,
//                                                 color: Colors.white,
//                                               ),
//                                               onSelected: controller.onSelected,
//                                               itemBuilder:
//                                                   (BuildContext context) {
//                                                 return controller.assetsCamp
//                                                     .map((String choice) {
//                                                   return PopupMenuItem<String>(
//                                                     value: choice,
//                                                     child: Text(choice),
//                                                   );
//                                                 }).toList();
//                                               },
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     if (isTradeAssets == true)
//                                       Column(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.start,
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             "POSID",
//                                             style: TextStyle(
//                                               color: Colors.black,
//                                               fontSize: 16.sp,
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                           ).marginOnly(
//                                             bottom: 5.h,
//                                           ),
//                                           MyInputField(
//                                             controller: controller.posId.value,
//                                             padding: EdgeInsets.symmetric(
//                                               vertical: 8.h,
//                                               horizontal: 8.w,
//                                             ),
//                                             textStyle: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 16.sp,
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                             hint: "POSID",
//                                           ),
//                                           Text(
//                                             "Type of Asset",
//                                             style: TextStyle(
//                                               color: Colors.black,
//                                               fontSize: 16.sp,
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                           ).marginOnly(
//                                             bottom: 5.h,
//                                             top: 5.h,
//                                           ),
//                                           MyInputField(
//                                             controller:
//                                                 controller.selectedAsset.value,
//                                             padding: EdgeInsets.symmetric(
//                                               vertical: 8.h,
//                                               horizontal: 8.w,
//                                             ),
//                                             readOnly: true,
//                                             textStyle: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 16.sp,
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                             hint: controller.selectedItem ??
//                                                 "Type Asset",
//                                             suffix: PopupMenuButton<String>(
//                                               icon: Icon(
//                                                 Icons.keyboard_arrow_down_sharp,
//                                                 color: Colors.white,
//                                               ),
//                                               onSelected: controller.onSelected,
//                                               itemBuilder:
//                                                   (BuildContext context) {
//                                                 return controller.assetsCamp
//                                                     .map((String choice) {
//                                                   return PopupMenuItem<String>(
//                                                     value: choice,
//                                                     child: Text(choice),
//                                                   );
//                                                 }).toList();
//                                               },
//                                             ),
//                                           ),
//                                           SizedBox(height: 10.h),
//                                           Text(
//                                             "Retailer Name",
//                                             style: TextStyle(
//                                               color: Colors.black,
//                                               fontSize: 16.sp,
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                           ).marginOnly(
//                                             bottom: 5.h,
//                                           ),
//                                           MyInputField(
//                                             controller:
//                                                 controller.retailerName.value,
//                                             padding: EdgeInsets.symmetric(
//                                               vertical: 8.h,
//                                               horizontal: 8.w,
//                                             ),
//                                             textStyle: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 16.sp,
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                             hint: "Retailer Name",
//                                           ),
//                                           SizedBox(height: 10.h),
//                                           Text(
//                                             "Retailer Address",
//                                             style: TextStyle(
//                                               color: Colors.black,
//                                               fontSize: 16.sp,
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                           ).marginOnly(
//                                             bottom: 5.h,
//                                           ),
//                                           MyInputField(
//                                             controller: controller
//                                                 .retailerAddress.value,
//                                             padding: EdgeInsets.symmetric(
//                                               vertical: 8.h,
//                                               horizontal: 8.w,
//                                             ),
//                                             textStyle: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 16.sp,
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                             hint: "Retailer Address",
//                                           ),
//                                         ],
//                                       ),
//                                     Align(
//                                       alignment: Alignment.centerLeft,
//                                       child: Text(
//                                         "Upload Pics",
//                                         style: TextStyle(
//                                           color: Colors.black,
//                                           fontSize: 16.sp,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ).marginOnly(
//                                         bottom: 5.h,
//                                       ),
//                                     ),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         CustomImagePickerContainer(
//                                           onImagePicked:
//                                               controller.onImagePicked,
//                                         ),
//                                         SizedBox(
//                                           width: 10.w,
//                                         ),
//                                         CustomImagePickerContainer(
//                                           onImagePicked:
//                                               controller.onImagePicked,
//                                         ),
//                                         SizedBox(
//                                           width: 10.w,
//                                         ),
//                                         CustomImagePickerContainer(
//                                           onImagePicked:
//                                               controller.onImagePicked,
//                                         ),
//                                       ],
//                                     ).marginOnly(
//                                       top: 10.h,
//                                     ),
//                                     SizedBox(
//                                       height: 10.w,
//                                     ),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         CustomImagePickerContainer(
//                                           onImagePicked:
//                                               controller.onImagePicked,
//                                         ),
//                                         SizedBox(
//                                           width: 10.w,
//                                         ),
//                                         CustomImagePickerContainer(
//                                           onImagePicked:
//                                               controller.onImagePicked,
//                                         ),
//                                         SizedBox(
//                                           width: 10.w,
//                                         ),
//                                         CustomImagePickerContainer(
//                                           onImagePicked:
//                                               controller.onImagePicked,
//                                         ),
//                                       ],
//                                     ),
//                                     SizedBox(height: 10.h),
//                                     Obx(() {
//                                       return CustomButton(
//                                         isLoading: controller.isLoading.value,
//                                         buttonColor: AppColors.buttonColor,
//                                         buttonText: "Upload Data",
//                                         onTap: () async {
//                                           await controller.saveData();
//                                         },
//                                       );
//                                     }).marginSymmetric(vertical: 8.h),
//                                   ],
//                                 )
//                               ],
//                             ).marginSymmetric(horizontal: 15.w),
//                           );
//                         });
//                       });
//                 });
//           }),
//     );
//   }
// }
