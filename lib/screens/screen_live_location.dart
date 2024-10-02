import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';

class LiveLocationScreen extends StatefulWidget {
  const LiveLocationScreen({Key? key}) : super(key: key);

  @override
  _LiveLocationScreenState createState() => _LiveLocationScreenState();
}

class _LiveLocationScreenState extends State<LiveLocationScreen> {
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  Position? _currentPosition;
  Placemark? _currentAddress;
  bool _loadingLocation = false;
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    setState(() {
      _loadingLocation = true;
    });

    bool permissionGranted = await _checkPermissionStatus();
    if (!permissionGranted) {
      setState(() {
        _loadingLocation = false;
      });
      return;
    }

    // Listen to location updates
    _positionStream = Geolocator.getPositionStream(
      // desiredAccuracy: LocationAccuracy.high,
    ).listen((Position position) {
      _currentPosition = position;
      _updateCameraPosition();
      _getAddressFromCurrentLocation();
    });
  }

  Future<void> _updateCameraPosition() async {
    if (_currentPosition == null) return;

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        zoom: 14.4746,
      ),
    ));
  }

  Future<bool> _checkPermissionStatus() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      Get.snackbar(
        'Permission Denied',
        'Location permissions are permanently denied, we cannot request permissions.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationEnabled) {
      Get.snackbar(
        'Location Disabled',
        'Please enable location services.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    return permission != LocationPermission.denied;
  }

  Future<void> _getAddressFromCurrentLocation() async {
    if (_currentPosition == null) return;

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      if (placemarks.isNotEmpty) {
        setState(() {
          _currentAddress = placemarks.first;
          _loadingLocation = false;
        });
      }
    } catch (e) {
      print('Error fetching address: $e');
      setState(() {
        _loadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Location"),
      ),
      body: _loadingLocation
          ? const Center(child: CircularProgressIndicator())
          : _currentPosition == null
          ? const Center(child: Text('Unable to fetch location'))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAddressInfo(),
          _buildGoogleMap(),
          _buildSaveLocationButton(),
        ],
      ),
    );
  }

  Widget _buildAddressInfo() {
    String address = _currentAddress != null
        ? '${_currentAddress!.locality}, ${_currentAddress!.subLocality}, ${_currentAddress!.country}'
        : 'Unknown address';
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        "Current Address: $address",
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildGoogleMap() {
    return Expanded(
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _initialCameraPosition,
        markers: _currentPosition != null
            ? {
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: LatLng(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            ),
          ),
        }
            : {},
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }

  Widget _buildSaveLocationButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: ElevatedButton(
        onPressed: () {
          Get.back(result: _currentAddress);
        },
        child: const Text('Save Location'),
      ),
    );
  }
}
