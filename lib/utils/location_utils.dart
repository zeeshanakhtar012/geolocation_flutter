import 'dart:math';

import 'package:Jazz/extensions/num_extensions.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';

Future<bool> checkPermissionStatus() async {
  var status = await Permission.locationWhenInUse.status;
  print(status);

  if (status != PermissionStatus.granted) {
    print(status);
    var requestStatus = await Permission.locationWhenInUse.request();
    if (requestStatus == PermissionStatus.granted) {
      return await enableLocationService();
    } else {
      return false;
    }
  } else {
    return await enableLocationService();
  }
}

Future<bool> enableLocationService() async {
  loc.Location location = loc.Location();
  bool enabled = await location.serviceEnabled();

  if (!enabled) {
    enabled = await location.requestService();
  }

  if (enabled) {
    var myPosition = await Geolocator.getCurrentPosition();
    // Update user location in your database, if needed
    // usersRef.doc(auth.FirebaseAuth.instance.currentUser!.uid).update({
    //   "latitude": myPosition.latitude,
    //   "longitude": myPosition.longitude,
    // });
  }

  return enabled;
}

double roundDouble(double value, int places) {
  num mod = pow(10.0, places);
  return ((value * mod).round().toDouble() / mod);
}

double getDistance(double lat1, double lng1, double lat2, double lng2) {
  double metersAway = Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
  final kmAway = metersAway / 1000;
  return kmAway.roundToNum(2);
}

Future<double> distanceBetweenAddresses(String address1, String address2) async {
  List<Location> locations1 = await locationFromAddress(address1);
  List<Location> locations2 = await locationFromAddress(address2);

  return getDistance(locations1[0].latitude, locations1[0].longitude, locations2[0].latitude, locations2[0].longitude);
}

Future<Location> getLocationFromAddress(String address) async {
  return (await locationFromAddress(address)).first;
}

Future<String?> getAddressFromLatLng(double lat, double lng) async {
  List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
  return placemarks.first.name;
}

Future<Placemark?> getAddressFromCurrentLocation() async {
  var position = await Geolocator.getCurrentPosition();
  List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
  print(placemarks);

  return placemarks.first;
}

Future<List<Location>> getLatLngFromAddress(String address) async {
  List<Location> latLng = await locationFromAddress(address);

  return latLng;
}
