import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../widgets/my_input_feild.dart';
import '../constants/colors.dart';
import '../controllers/controller_add_data.dart';
import '../model/user.dart';
import '../utils/location_utils.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_image_picker_container.dart';

class ScreenModuleIntelligence extends StatelessWidget {
  User? user;
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
          ),
        ),
        title: Text(
          "Market Intelligence",
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
          return FutureBuilder<Position>(
            future: Geolocator.getCurrentPosition(),
            builder: (context, positionSnapshot) {
              if (positionSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              var position = positionSnapshot.data;
              return FutureBuilder<Placemark?>(
                future: getAddressFromCurrentLocation(),
                builder: (context, addressSnapshot) {
                  if (addressSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  var address = addressSnapshot.data;
                  if (address == null) {
                    log("Address is null.");
                    controller.address.value = "Unknown location"; // Handle the null case as needed
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
                                    void Function(void Function()) setState) {
                                  return GoogleMap(
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
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Container(
                            padding: EdgeInsets.only(left: 10.w),
                            width: Get.width,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.r),
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.green,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: ListTile(
                                title: Text(
                                  "Your Current Location",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16.sp,
                                  ),
                                ),
                                subtitle: Text(
                                  controller.address.value,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.sp,
                                  ),
                                ),
                                leading: Icon(
                                  Icons.location_on,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          _buildAssetTypeSection(),
                          SizedBox(height: 10.h),
                          _buildCompanyAssetsSection(),
                          SizedBox(height: 10.h),
                          _buildImageUploadSection(),
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

  Widget _buildAssetTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Type of Asset",
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

  Widget _buildCompanyAssetsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Company Assets",
          style: TextStyle(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.w500),
        ).marginOnly(bottom: 5.h),
        GetBuilder<ControllerAuthentication>(
          builder: (_) {
            return MyInputField(
              controller: TextEditingController(text: controller.selectedRetailerDetails.join(', ')),
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
              readOnly: true,
              textStyle: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w500),
              hint: controller.selectedRetailerDetails.isNotEmpty
                  ? controller.selectedRetailerDetails.join(', ')
                  : "Company Asset",
              suffix: PopupMenuButton<String>(
                icon: Icon(Icons.keyboard_arrow_down_sharp, color: Colors.white),
                onSelected: (String selected) {
                  if (selected == "Others (Specify)") {
                    controller.showOthersInput.value = true;
                  } else {
                    controller.showOthersInput.value = false;
                    if (!controller.selectedRetailerDetails.contains(selected)) {
                      controller.selectedRetailerDetails.add(selected);
                    }
                  }
                  controller.update(); // Trigger UI update
                },
                itemBuilder: (BuildContext context) {
                  return controller.retailerDetails.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Row(
                        children: [
                          Obx(() => Checkbox(
                            value: controller.selectedRetailerDetails.contains(choice),
                            onChanged: (bool? value) {
                              if (value == true) {
                                controller.selectedRetailerDetails.add(choice);
                                if (choice == "Others (Specify)") {
                                  controller.showOthersInput.value = true;
                                }
                              } else {
                                controller.selectedRetailerDetails.remove(choice);
                                if (choice == "Others (Specify)") {
                                  controller.showOthersInput.value = false;
                                  controller.othersController.value;
                                }
                              }
                              controller.update();
                            },
                          )),
                          Text(choice),
                        ],
                      ),
                    );
                  }).toList();
                },
              ),
            );
          },
        ),
        Obx(() {
          return controller.showOthersInput.value
              ? Padding(
            padding: EdgeInsets.only(top: 10.h),
            child: TextFormField(
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
              controller: controller.othersController.value,
              decoration: InputDecoration(
                labelText: 'Specify Other',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {},
            ),
          )
              : Container();
        }),
      ],
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Upload Pics",
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ).marginOnly(bottom: 5.h),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomImagePickerContainer(
              onImagePicked: controller.onImagePicked,
            ),
            SizedBox(width: 10.w),
            CustomImagePickerContainer(
              onImagePicked: controller.onImagePicked,
            ),
            SizedBox(width: 10.w),
            CustomImagePickerContainer(
              onImagePicked: controller.onImagePicked,
            ),
          ],
        ).marginOnly(top: 10.h),
        SizedBox(height: 10.w),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomImagePickerContainer(
              onImagePicked: controller.onImagePicked,
            ),
            SizedBox(width: 10.w),
            CustomImagePickerContainer(
              onImagePicked: controller.onImagePicked,
            ),
            SizedBox(width: 10.w),
            CustomImagePickerContainer(
              onImagePicked: controller.onImagePicked,
            ),
          ],
        ),
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
          // for (String imagePath in controller.images) {
          //   await controller.uploadImageToStorage(File(imagePath));
          // }

          var dateTime = DateTime.now();
          String moduleName = "MarketIntelligence";
          Map<String, dynamic> moduleData = {
            "location": controller.address.value,
            "assetType": controller.selectedAsset.value.text,
            "othersDetails": controller.othersController.value.text,
            "companyAsset": controller.selectedRetailerDetails.value.join(', '),
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

  Future<bool> checkPermissionStatus() async {
    var status = await Geolocator.checkPermission();
    if (status == LocationPermission.denied) {
      status = await Geolocator.requestPermission();
      if (status == LocationPermission.denied) {
        return false;
      }
    }
    return true;
  }
}
