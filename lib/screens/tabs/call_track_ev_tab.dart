import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CallTrackEvTab extends StatefulWidget {
  final String? studentName;
  final String? enrollmentNumber;

  const CallTrackEvTab({super.key, this.studentName, this.enrollmentNumber});

  @override
  State<CallTrackEvTab> createState() => _CallTrackEvTabState();
}

class _CallTrackEvTabState extends State<CallTrackEvTab> {
  static const LatLng _campusCenter = LatLng(32.63445556, 75.01293333);
  static const LatLng _defaultStudentLocation = LatLng(32.6336, 75.0153);

  static const String _liveCollection = "ev_tracking";
  static const String _liveDocId = "active_ev";

  late LatLng _evPosition;
  late Timer _simulatedMovementTimer;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _evLiveSub;

  final List<LatLng> _evRoute = const [
    LatLng(32.6341, 75.0090),
    LatLng(32.6348, 75.0104),
    LatLng(32.6351, 75.0119),
    LatLng(32.6347, 75.0136),
    LatLng(32.6339, 75.0148),
    LatLng(32.6330, 75.0157),
    LatLng(32.6336, 75.0153),
  ];

  final List<LatLng> _liveTrail = <LatLng>[];

  int _routeIndex = 0;
  bool _isEvCalled = false;
  bool _hasLiveSignal = false;
  String _pickupPoint = "Main Gate";
  String _etaLabel = "8 mins";
  String _driverName = "Driver TBD";
  String _statusLabel = "EV is circulating on campus";
  String _vehicleLabel = "EV-01";
  DateTime? _lastGpsTime;
  String? _trackingError;
  bool _mapInitError = false;

  static const List<String> _pickupPoints = <String>[
    "Main Gate",
    "Chanakya Bhawan",
    "DDE Building",
    "Febricated Building",
    "Tunnel",
    "PMMMM Block",
    "ISRO Building",
    "Aryabhatta Building",
    "J&K Bank"

  ];

  @override
  void initState() {
    super.initState();
    _evPosition = _evRoute.first;
    _simulatedMovementTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) => _moveEvFallback(),
    );
    _startLiveTracking();
  }

  @override
  void dispose() {
    _simulatedMovementTimer.cancel();
    _evLiveSub?.cancel();
    super.dispose();
  }

  void _startLiveTracking() {
    _evLiveSub = FirebaseFirestore.instance
        .collection(_liveCollection)
        .doc(_liveDocId)
        .snapshots()
        .listen((snapshot) {
          if (!mounted || !snapshot.exists) return;
          final data = snapshot.data();
          if (data == null) return;

          final livePosition = _extractLatLng(data);
          if (livePosition == null) return;

          setState(() {
            _hasLiveSignal = true;
            _evPosition = livePosition;
            _pushToTrail(livePosition);
            _driverName = (data["driverName"] as String?)?.trim().isNotEmpty ==
                    true
                ? (data["driverName"] as String)
                : _driverName;
            _vehicleLabel = (data["vehicleId"] as String?)?.trim().isNotEmpty ==
                    true
                ? (data["vehicleId"] as String)
                : _vehicleLabel;
            final int? etaMin = _asInt(data["etaMinutes"]);
            if (etaMin != null && etaMin >= 0) {
              _etaLabel = "$etaMin mins";
            }
            final status = (data["status"] as String?)?.trim();
            if (status != null && status.isNotEmpty) {
              _statusLabel = status;
            }
            _lastGpsTime = _extractTimestamp(data["updatedAt"]);
            _trackingError = null;
          });
        }, onError: (Object _) {
          if (!mounted) return;
          setState(() {
            _trackingError = "Live tracking stream error.";
          });
        });
  }

  LatLng? _extractLatLng(Map<String, dynamic> data) {
    if (data["position"] is GeoPoint) {
      final point = data["position"] as GeoPoint;
      return LatLng(point.latitude, point.longitude);
    }
    final lat = _asDouble(data["latitude"]);
    final lng = _asDouble(data["longitude"]);
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  void _pushToTrail(LatLng point) {
    if (_liveTrail.isNotEmpty) {
      final last = _liveTrail.last;
      if ((last.latitude - point.latitude).abs() < 0.00001 &&
          (last.longitude - point.longitude).abs() < 0.00001) {
        return;
      }
    }
    _liveTrail.add(point);
    if (_liveTrail.length > 40) {
      _liveTrail.removeAt(0);
    }
  }

  DateTime? _extractTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  double? _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  void _moveEvFallback() {
    if (!mounted || _hasLiveSignal) return;
    setState(() {
      _routeIndex = (_routeIndex + 1) % _evRoute.length;
      _evPosition = _evRoute[_routeIndex];
      if (_isEvCalled) {
        final mins = (8 - _routeIndex).clamp(2, 12);
        _etaLabel = "$mins mins";
        _statusLabel = "EV is on the way to $_pickupPoint";
      }
    });
  }

  // Keeps hot-reloaded older timer callbacks from crashing after method rename.
  void _moveEv() {
    _moveEvFallback();
  }

  Future<void> _callEv() async {
    setState(() {
      _isEvCalled = true;
      _statusLabel = "Call sent. EV is heading to $_pickupPoint";
    });

    try {
      await FirebaseFirestore.instance.collection("ev_requests").add({
        "pickupPoint": _pickupPoint,
        "studentName": widget.studentName ?? "Student",
        "enrollmentNumber": widget.enrollmentNumber ?? "",
        "studentLatitude": _defaultStudentLocation.latitude,
        "studentLongitude": _defaultStudentLocation.longitude,
        "status": "requested",
        "requestedAt": FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("EV called for $_pickupPoint"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Could not send EV call right now."),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Set<Marker> _markers() {
    return <Marker>{
      Marker(
        markerId: const MarkerId("ev_marker"),
        position: _evPosition,
        infoWindow: InfoWindow(
          title: "CUJ Electric Vehicle ($_vehicleLabel)",
          snippet: _hasLiveSignal ? "Live GPS" : "Default simulation",
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
      const Marker(
        markerId: MarkerId("student_marker"),
        position: _defaultStudentLocation,
        infoWindow: InfoWindow(
          title: "Your Location",
          snippet: "Default location for now",
        ),
      ),
      Marker(
        markerId: const MarkerId("campus_center"),
        position: _campusCenter,
        infoWindow: const InfoWindow(
          title: "Central University of Jammu",
          snippet: "Campus center",
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    };
  }

  Set<Polyline> _polylines() {
    final routePoints = _hasLiveSignal && _liveTrail.length > 1
        ? _liveTrail
        : _evRoute;
    return <Polyline>{
      Polyline(
        polylineId: const PolylineId("ev_route"),
        points: routePoints,
        color: const Color(0xFF0F766E),
        width: 4,
      ),
      const Polyline(
        polylineId: PolylineId("pickup_line"),
        points: <LatLng>[_defaultStudentLocation, _campusCenter],
        color: Color(0xFF334155),
        width: 2,
      ),
    };
  }

  String _lastUpdatedLabel() {
    if (_trackingError != null) return _trackingError!;
    final last = _lastGpsTime;
    if (last == null) return "Last update: waiting for GPS";
    final diff = DateTime.now().difference(last);
    if (diff.inSeconds < 60) return "Last update: just now";
    if (diff.inMinutes < 60) return "Last update: ${diff.inMinutes} min ago";
    return "Last update: ${diff.inHours} hr ago";
  }

  bool get _canRenderGoogleMap {
    return !_mapInitError;
  }

  Widget _buildMapArea() {
    if (!_canRenderGoogleMap) {
      return Container(
        color: const Color(0xFFF8FAFC),
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.map_outlined, size: 44, color: Color(0xFF334155)),
              SizedBox(height: 10),
              Text(
                "Map unavailable",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 6),
              Text(
                "Configure Google Maps API key to enable live map safely.",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return GoogleMap(
      initialCameraPosition: const CameraPosition(target: _campusCenter, zoom: 15.2),
      mapType: MapType.normal,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      markers: _markers(),
      polylines: _polylines(),
      onMapCreated: (_) {
        if (!mounted) return;
        setState(() {
          _mapInitError = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Call/Track EV")),
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 0.8,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Call Electric Vehicle",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _hasLiveSignal
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              _hasLiveSignal ? "LIVE GPS" : "SIMULATION",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _hasLiveSignal
                                    ? const Color(0xFF166534)
                                    : const Color(0xFF334155),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _pickupPoint,
                              decoration: const InputDecoration(
                                labelText: "Pickup Point",
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: _pickupPoints
                                  .map(
                                    (point) => DropdownMenuItem<String>(
                                      value: point,
                                      child: Text(point),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() {
                                  _pickupPoint = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: _callEv,
                            icon: const Icon(Icons.call),
                            label: const Text("Call EV"),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildMapArea(),
                ),
                const SizedBox(height: 132),
              ],
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _statusLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 18),
                        const SizedBox(width: 6),
                        Text("Arrival: $_etaLabel"),
                        const Spacer(),
                        const Icon(Icons.electric_car, size: 18),
                        const SizedBox(width: 6),
                        Text(_isEvCalled ? "On Trip" : "Available"),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 18),
                        const SizedBox(width: 6),
                        Expanded(child: Text("Driver: $_driverName")),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.place, size: 18),
                        const SizedBox(width: 6),
                        Expanded(child: Text("You are at: $_pickupPoint")),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _lastUpdatedLabel(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
