import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class TransportPage extends StatefulWidget {
  const TransportPage({super.key});

  @override
  State<TransportPage> createState() => _TransportPageState();
}

class _TransportPageState extends State<TransportPage>
    with SingleTickerProviderStateMixin {
  String routeMessage = "Detecting nearest stop...";
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final double cujLat = 32.63445556;
  final double cujLng = 75.01293333;

  @override
  void initState() {
    super.initState();
    _detectLocation();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _detectLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        routeMessage = "Please enable location services.";
      });
      return;
    }

    await Geolocator.requestPermission();

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    double distance = Geolocator.distanceBetween(
      cujLat,
      cujLng,
      position.latitude,
      position.longitude,
    );

    setState(() {
      if (distance < 2000) {
        routeMessage =
            "Nearest Stop: Rahya-Suchani Stop\nRoute: CUJ -> Main Road -> Jammu City";
      } else {
        routeMessage =
            "You are ${distance ~/ 100000} km away.\nSuggested: Take local bus to CUJ Stop first.";
      }
    });
  }

  Future<void> _openChaloApp() async {
    const packageName = "app.zophop";
    final Uri playStoreUri =
        Uri.parse("https://play.google.com/store/apps/details?id=$packageName");

    if (Platform.isAndroid) {
      try {
        const intent = AndroidIntent(
          action: "action_main",
          category: "category_launcher",
          package: packageName,
        );
        await intent.launch();
        return;
      } catch (_) {
        final Uri marketUri = Uri.parse("market://details?id=$packageName");
        if (await canLaunchUrl(marketUri)) {
          await launchUrl(marketUri, mode: LaunchMode.externalApplication);
          return;
        }
      }
    }

    await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("E-Bus Service")),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Nearest Bus Route",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    routeMessage,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.directions_bus),
                  label: const Text("Book via Chal Bus App"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  onPressed: _openChaloApp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
