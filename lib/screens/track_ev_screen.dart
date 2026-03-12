import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';

class TrackEVScreen extends StatefulWidget {
  const TrackEVScreen({super.key});

  @override
  State<TrackEVScreen> createState() => _TrackEVScreenState();
}

class _TrackEVScreenState extends State<TrackEVScreen> {
  GoogleMapController? mapController;
  StreamSubscription<DatabaseEvent>? _locationSubscription;

 LatLng evLocation = const LatLng(32.6356171, 75.0097347);

  final DatabaseReference dbRef =
      FirebaseDatabase.instance.ref("ev_locations/ev1");

  @override
  void initState() {
    super.initState();
    listenEVLocation();
  }

  void listenEVLocation() {
    _locationSubscription = dbRef.onValue.listen((event) {
      final value = event.snapshot.value;
      if (value is! Map) return;

      final lat = _toDouble(value["lat"]);
      final lng = _toDouble(value["lng"]);
      if (lat == null || lng == null) return;
      if (!mounted) return;

      setState(() {
        evLocation = LatLng(lat, lng);
      });

      mapController?.animateCamera(CameraUpdate.newLatLng(evLocation));
    });
  }

  double? _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Track University EV"),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: evLocation,
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: const MarkerId("ev"),
            position: evLocation,
            infoWindow: const InfoWindow(title: "University EV"),
          ),
        },
        onMapCreated: (controller) {
          mapController = controller;
        },
        myLocationEnabled: false,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
