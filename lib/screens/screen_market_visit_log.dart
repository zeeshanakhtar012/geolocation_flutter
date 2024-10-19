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

class ScreenMarketVisitLog extends StatelessWidget {
  ScreenMarketVisitLog({Key? key}) : super(key: key);

  final Completer<GoogleMapController> _controller = Completer();
  final ControllerAuthentication controller = Get.put(ControllerAuthentication());

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
          ),
        ),
        title: Text(
          "Market Visit Log",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FutureBuilder<bool>(
        future: checkPermissionStatus(),
        builder: (context, permissionSnapshot) {
          if (permissionSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return FutureBuilder<Position>(
            future: Geolocator.getCurrentPosition(),
            builder: (context, positionSnapshot) {
              if (positionSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (positionSnapshot.hasError) {
                return Center(child: Text("Error fetching location."));
              }

              var position = positionSnapshot.data;
              return FutureBuilder<Placemark?>(
                future: getAddressFromCurrentLocation(),
                builder: (context, addressSnapshot) {
                  if (addressSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (addressSnapshot.hasError) {
                    return Center(child: Text("Error fetching address."));
                  }

                  var address = addressSnapshot.data;
                  controller.address.value = address == null
                      ? "Unknown location"
                      : "${address.subLocality ?? ""} ${address.locality ?? ""} ${address.postalCode ?? ""} ${address.country ?? ""}";
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
                              child: GoogleMap(
                                mapType: MapType.hybrid,
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(position!.latitude, position.longitude),
                                  zoom: 14.4746,
                                ),
                                markers: {
                                  Marker(
                                    markerId: const MarkerId('currentLocation'),
                                    position: LatLng(position.latitude, position.longitude),
                                  ),
                                },
                                onMapCreated: (GoogleMapController controller) {
                                  _controller.complete(controller);
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          buildInputFields(),
                          SizedBox(height: 10.h),
                          buildImagePickerRow(),
                          SizedBox(height: 10.h),
                          buildImagePickerRow(),
                          SizedBox(height: 10.h),
                          buildUploadButton(),
                        ],
                      ).marginSymmetric(horizontal: 15.w),
                    );
                  });
                },
              );
            },
          );
        },
      ),
    );
  }

  Column buildInputFields() {
    return Column(
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
    );
  }

  Widget buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.w500),
    ).marginOnly(bottom: 5.h);
  }

  Row buildImagePickerRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ...List.generate(3, (index) {
          return CustomImagePickerContainer(
            onImagePicked: controller.onImagePicked,
          );
        }),
      ],
    );
  }

  Widget buildUploadButton() {
    return Obx(() {
      return CustomButton(
        isLoading: controller.isLoading.value,
        buttonColor: AppColors.buttonColor,
        buttonText: "Upload Data",
        onTap: () async {
          controller.isLoading.value = true;
          for (String imagePath in controller.images) {
            await controller.uploadImageToStorage(File(imagePath));
          }

          var dateTime = DateTime.now();
          String moduleName = "MarketVisit";
          Map<String, dynamic> moduleData = {
            "location": controller.address.value,
            "retailerName": controller.retailerName.value.text,
            "retailerAddress": controller.retailerAddress.value.text,
            "visitDate": dateTime.toIso8601String(),
            "images": controller.images.value,
            "time": dateTime,
          };
          await controller.uploadModuleData(moduleName, moduleData);
          controller.isLoading.value = false;
        },
      ).marginSymmetric(vertical: 8.h);
    });
  }
}
