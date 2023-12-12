import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
import 'dart:async';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:permission_handler/permission_handler.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late Future<void> _locationFuture;
  Completer<maps.GoogleMapController> _controller = Completer();
  Set<maps.Marker> _markers = Set<maps.Marker>();
  List<maps.LatLng> _polylineCoordinates = [];
  Set<maps.Polyline> _polylines = <maps.Polyline>{};

  // late maps.LatLng _origin;
  maps.LatLng _origin = const maps.LatLng(3.974341, 102.438057); // Default origin
  maps.LatLng _destination = const maps.LatLng(0.0, 0.0); // Default destination

  @override
  void initState() {
    super.initState();
    _locationFuture = _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    var status = await Permission.location.request();

    if (status == PermissionStatus.granted) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _origin = maps.LatLng(position.latitude, position.longitude);
        _addMarker(_origin, "You're Here");
        _fetchPetLocation(); // Fetch pet location after getting user location
      });
    } else {
      print("Location permission denied");
      // Handle denied permission (show a message, ask again, etc.)
    }
  }

  void _addMarker(maps.LatLng position, String id) {
    _markers.add(maps.Marker(
      markerId: maps.MarkerId(id),
      position: position,
      infoWindow: maps.InfoWindow(title: id),
    ));
  }

  void _getPolyline() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyBTobCLW6QcSuCUEAL2ocFgWajbBm7NQ3I',
      PointLatLng(_origin.latitude, _origin.longitude),
      PointLatLng(_destination.latitude, _destination.longitude),
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        _polylineCoordinates.add(maps.LatLng(point.latitude, point.longitude));
      });
    }

    setState(() {
      _polylines.add(maps.Polyline(
        polylineId: const maps.PolylineId("poly"),
        color: Colors.blue,
        points: _polylineCoordinates,
        width: 5,
      ));
    });
  }

  Future<void> _fetchPetLocation() async {
    // Get the UID of the logged-in user
    User? user = FirebaseAuth.instance.currentUser;
    String userUID = user!.uid;

    DatabaseReference petRef =
        FirebaseDatabase.instance.reference().child('pet').child(userUID);
    DatabaseEvent petSnapshot = await petRef.once();
    Map<dynamic, dynamic>? petData =
        petSnapshot.snapshot.value as Map<dynamic, dynamic>?;

    if (petData != null) {
      // Use '??' to check for null and then try to parse to double
      double petLatitude =
          double.tryParse(petData['latitude'].toString()) ?? 0.0;
      double petLongitude =
          double.tryParse(petData['longitude'].toString()) ?? 0.0;

      setState(() {
        _destination = maps.LatLng(petLatitude, petLongitude);
        _addMarker(_destination, "Your Pet");
        _getPolyline();
      });
    } else {
      print('Pet data not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'asset/logo.jpg', // Replace with the path to your logo asset
              height: 30, // Adjust the height as needed
            ),
            const SizedBox(
                width: 8), // Add some spacing between the logo and the title
            const Text('Pet Location'),
          ],
        ),
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<void>(
        future: _locationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return maps.GoogleMap(
              mapType: maps.MapType.normal,
              markers: _markers,
              polylines: _polylines,
              initialCameraPosition: maps.CameraPosition(
                target: _origin,
                zoom: 12.0,
              ),
              onMapCreated: (maps.GoogleMapController controller) {
                _controller.complete(controller);
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
