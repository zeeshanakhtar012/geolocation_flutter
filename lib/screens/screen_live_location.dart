import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';

import '../controllers/controller_add_data.dart';

class MapScreen extends StatelessWidget {
  final ControllerAuthentication controllerLocation = Get.put(ControllerAuthentication());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Location"),
      ),
      body: Obx(() {
        if (controllerLocation.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        if (controllerLocation.lat.value == 0.0 && controllerLocation.lng.value == 0.0) {
          return Center(child: Text("No location data available"));
        }
        return GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(controllerLocation.lat.value, controllerLocation.lng.value),
            zoom: 14.0,
          ),
          markers: {
            Marker(
              markerId: MarkerId('location'),
              position: LatLng(controllerLocation.lat.value, controllerLocation.lng.value),
              infoWindow: InfoWindow(
                title: "User Location",
                snippet: "Lat: ${controllerLocation.lat.value}, Lng: ${controllerLocation.lng.value}",
              ),
            )
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controllerLocation.getLocation();
          controllerLocation.saveData(controllerLocation.lat.value, controllerLocation.lng.value);
        },
        child: Icon(Icons.location_searching),
      ),
    );
  }
}
