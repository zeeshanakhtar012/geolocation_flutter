import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
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
            color: Colors.black,
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
          textStyle: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
          hint: "Enter POS ID",
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
        SizedBox(height: 10.h),
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

          // Log the values to see if they are correct
          log("retailer address == $retailerAddress");
          log("retailer name == $retailerName");
          log("location == $location");
          Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);
          double latitude = position.latitude;
          double longitude = position.longitude;
          log("Latitude: $latitude, Longitude: $longitude");
          // Check if the retailer fields are not empty before uploading
          if (retailerName.isNotEmpty && retailerAddress.isNotEmpty) {
            String moduleName = "MarketVisit";
            Map<String, dynamic> moduleData = {
              "location": location,
              "retailerName": retailerName,
              "retailerAddress": retailerAddress,
              "visitDate": dateTime.toIso8601String(),
              "images": controller.images.value,
              "latitude": latitude,
              "longitude": longitude,
              "time": dateTime,
            };

            // Call the function to upload the data
            await controller.uploadModuleData(moduleName, moduleData);

            // Clear the fields after upload
            controller.retailerName.value.clear();
            controller.retailerAddress.value.clear();
            controller.images.value = [];
          } else {
            log("Retailer Name or Address is empty.");
            Get.snackbar("Error", "Please fill in both retailer name and address.",
                backgroundColor: Colors.red);
          }

          controller.isLoading.value = false;
        },
      ).marginSymmetric(vertical: 8.h);
    });
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
}
