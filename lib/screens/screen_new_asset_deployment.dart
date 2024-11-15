import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../widgets/my_input_feild.dart';
import '../constants/colors.dart';
import '../controllers/controller_add_data.dart';
import '../utils/location_utils.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_image_picker_container.dart';

class ScreenNewAssetDeployment extends StatelessWidget {

  ScreenNewAssetDeployment({
    Key? key,
  }) : super(key: key);

  Completer<GoogleMapController> _controller = Completer();
  ControllerAuthentication controller = Get.put(ControllerAuthentication());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
          "New Asset Deployment",
          style: TextStyle(
              color: Colors.black,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600),
        ),
        // actions: [
        //   TextButton(onPressed: (){
        //     Get.to(ScreenAddNumberWhiteList());
        //   }, child: Text("Add Number",style: TextStyle(color: Colors.green),))
        // ],
      ),
      body: FutureBuilder<bool>(
          future: checkPermissionStatus(),
          builder: (context, snapshot) {
            return FutureBuilder<Position>(
                future: Geolocator.getCurrentPosition(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: CircularProgressIndicator(
                          // color: const Color(0xFF65B901),
                          // strokeWidth: 3,
                        ));
                  }
                  var position = snapshot.data;
                  return FutureBuilder<Placemark?>(
                      future: getAddressFromCurrentLocation(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                              child: CircularProgressIndicator(
                                // color: const Color(0xFF65B901),
                                // strokeWidth: 3,
                              ));
                        }
                        var address = snapshot.data;
                        if (address == null) {
                          log("Address is null.");
                          controller.address.value = "Unknown location"; // or handle the null case as needed
                        } else {
                          controller.address.value =
                          "${address.subLocality ?? ""} ${address.locality ?? ""} ${address.postalCode ?? ""} ${address.country ?? ""}";
                        }
                        log("Current address == ${controller.address.value}");

                        return Obx(() {
                          return SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(
                                  height: 350.h,
                                  width: 350.w,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20.r),
                                    child: StatefulBuilder(
                                      builder: (BuildContext context,
                                          void Function(void Function())
                                          setState) {
                                        return GoogleMap(
                                          mapType: MapType.hybrid,
                                          initialCameraPosition: CameraPosition(
                                            target: LatLng(position!.latitude,
                                                position.longitude),
                                            zoom: 14.4746,
                                          ),
                                          markers: {
                                            Marker(
                                              markerId: const MarkerId(
                                                  'currentLocation'),
                                              position: LatLng(
                                                  position.latitude,
                                                  position.longitude),
                                            ),
                                          },
                                          onMapCreated:
                                              (GoogleMapController controller) {
                                            _controller.complete(controller);
                                          },
                                          gestureRecognizers: {
                                            Factory<OneSequenceGestureRecognizer>(
                                                  () => EagerGestureRecognizer(),
                                            ),
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10.h,
                                ),
                                Column(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        buildLabel("POSID"),
                                        MyInputField(
                                          controller: controller.posid.value,
                                          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
                                          textStyle: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w500),
                                          hint: "POSID",
                                        ),
                                        SizedBox(height: 10.h),
                                        ElevatedButton(
                                          onPressed: () {
                                            controller.searchRetailersByPosId(controller.posid.value.text);
                                          },
                                          child: Text('Search Retailer'),
                                        ),
                                        SizedBox(height: 10.h),
                                        buildLabel("Retailer Name"),
                                        MyInputField(
                                          controller: controller.retailerName.value,
                                          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
                                          textStyle: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w500),
                                          hint: controller.retailerName.value.text.isEmpty ? "Retailer Name" : controller.retailerName.value.text,
                                        ),
                                        SizedBox(height: 10.h),
                                        buildLabel("Retailer Address"),
                                        MyInputField(
                                          controller: controller.retailerAddress.value,
                                          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
                                          textStyle: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w500),
                                          hint: controller.retailerAddress.value.text.isEmpty ? "Retailer Address" : controller.retailerAddress.value.text,
                                        ),
                                        SizedBox(height: 10.h),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10.w,
                                    ),
                                    _buildAssetTypeSection(),
                                    SizedBox(
                                      height: 10.w,
                                    ),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "Upload Pics",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ).marginOnly(
                                        bottom: 5.h,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomImagePickerContainer(
                                          onImagePicked:
                                          controller.onImagePicked,
                                        ),
                                        SizedBox(
                                          width: 10.w,
                                        ),
                                        CustomImagePickerContainer(
                                          onImagePicked:
                                          controller.onImagePicked,
                                        ),
                                        SizedBox(
                                          width: 10.w,
                                        ),
                                        CustomImagePickerContainer(
                                          onImagePicked:
                                          controller.onImagePicked,
                                        ),
                                      ],
                                    ).marginOnly(
                                      top: 10.h,
                                    ),
                                    SizedBox(
                                      height: 10.w,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomImagePickerContainer(
                                          onImagePicked:
                                          controller.onImagePicked,
                                        ),
                                        SizedBox(
                                          width: 10.w,
                                        ),
                                        CustomImagePickerContainer(
                                          onImagePicked:
                                          controller.onImagePicked,
                                        ),
                                        SizedBox(
                                          width: 10.w,
                                        ),
                                        CustomImagePickerContainer(
                                          onImagePicked:
                                          controller.onImagePicked,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10.h),
                                    buildUploadButton(),
                                  ],
                                )
                              ],
                            ).marginSymmetric(horizontal: 15.w),
                          );
                        });
                      });
                });
          }),
    );
  }
  Widget _buildAssetTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Company Asset",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ).marginOnly(bottom: 5.h),
        Obx(() {
          return MyInputField(
            controller: controller.selectedAsset.value,
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
            readOnly: true,
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
            hint: controller.selectedItem ?? "Type Asset",
            suffix: PopupMenuButton<String>(
              icon: Icon(
                Icons.keyboard_arrow_down_sharp,
                color: Colors.white,
              ),
              onSelected: controller.onSelected,
              itemBuilder: (BuildContext context) {
                return controller.assetsCamp.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          );
        }),
      ],
    );
  }
  Widget buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.w500),
    ).marginOnly(bottom: 5.h);
  }
  Widget buildUploadButton() {
    return Obx(() {
      return CustomButton(
        isLoading: controller.isLoading.value,
        buttonColor: AppColors.buttonColor,
        buttonText: "Upload Data",
        onTap: () async {
          controller.isLoading.value = true;
          // for (String imagePath in controller.images) {
          //   await controller.uploadImageToStorage(File(imagePath));
          // }

          var dateTime = DateTime.now();
          String moduleName = "NewAsset";
          Map<String, dynamic> moduleData = {
            "location": controller.address.value,
            "retailerName": controller.retailerName.value.text,
            "retailerAddress": controller.retailerAddress.value.text,
            "assetType": controller.selectedAsset.value.text,
            "visitDate": dateTime.toIso8601String(),
            "images": controller.images.value,
            "time": dateTime,
          };
          await controller.uploadModuleData(moduleName, moduleData);
          controller.retailerName.value.clear();
          controller.retailerAddress.value.clear();
          controller.selectedAsset.value.clear();
          controller.selectedRetailerDetails.value.clear();
          controller.images.value = [];
          controller.isLoading.value = false;
        },
      ).marginSymmetric(vertical: 8.h);
    });
  }
}
