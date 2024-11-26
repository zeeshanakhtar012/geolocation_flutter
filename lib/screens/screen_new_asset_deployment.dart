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
              color: Colors.black,
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
                                    retailerDetails(),
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
                                    imagesDetails(),
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
  Widget imagesDetails() {
    return Column(
      children: [
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
      ],
    );
  }
  Widget retailerDetails() {
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
        Obx(() => MyInputField(
          controller: controller.retailerName.value,
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
          textStyle: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
          hint: controller.retailerNameHint.value.isEmpty
              ? "Retailer Name"
              : controller.retailerNameHint.value,
        )),
        SizedBox(height: 10.h),
        buildLabel("Retailer Address"),
        Obx(() => MyInputField(
          controller: controller.retailerAddress.value,
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
          textStyle: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
          hint: controller.retailerAddressHint.value.isEmpty
              ? "Retailer Address"
              : controller.retailerAddressHint.value,
        )),
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

          // Retrieving values from controller or the search function
          String retailerName = controller.retailerName.value.text;
          String retailerAddress = controller.retailerAddress.value.text;
          String location = controller.address.value;
          var dateTime = DateTime.now();

          // If the searchRetailersByPosId function fetched data, use that data
          if (retailerName.isEmpty || retailerAddress.isEmpty) {
            retailerName = controller.retailerNameHint.value;
            retailerAddress = controller.retailerAddressHint.value;
          }

          // Log the values to check if they are correct
          log("retailer address == $retailerAddress");
          log("retailer name == $retailerName");
          log("location == $location");
          Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);
          double latitude = position.latitude;
          double longitude = position.longitude;
          log("Latitude: $latitude, Longitude: $longitude");

          // Check if both retailerName and retailerAddress are not empty
          if (retailerName.isNotEmpty && retailerAddress.isNotEmpty) {
            Map<String, dynamic> moduleData = {
              "location": controller.address.value,
              "retailerName": retailerName,
              "retailerAddress": retailerAddress,
              "assetType": controller.selectedAsset.value.text,
              "visitDate": dateTime.toIso8601String(),
              "images": controller.images.value,
              "latitude": latitude,
              "longitude": longitude,
              "time": dateTime,
            };

            log("moduleData == $moduleData");

            // Proceed with uploading the data
            String moduleName = "NewAsset";
            await controller.uploadModuleData(moduleName, moduleData);

            // Clear the values after upload
            controller.retailerName.value.clear();
            controller.retailerAddress.value.clear();
            controller.selectedAsset.value.clear();
            controller.selectedRetailerDetails.value.clear();
            controller.images.value = [];
          } else {
            // Show an error or Snackbar if the fields are empty
            log("Retailer Name or Address is empty. Data not uploaded.");
            // You can also show a Snackbar here
          }

          controller.isLoading.value = false;
        },
      ).marginSymmetric(vertical: 8.h);
    });
  }

}
