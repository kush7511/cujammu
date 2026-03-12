import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cuj/models/student.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'home_screen.dart';
import '../services/app_settings_service.dart';
import 'admin_dashboard.dart';


class LoginScreen extends StatefulWidget {
  final AppSettings settings;
  final ValueChanged<bool> onThemeChanged;
  final ValueChanged<bool> onNotificationsChanged;
  final ValueChanged<bool> onBiometricLoginChanged;

  const LoginScreen({
    super.key,
    required this.settings,
    required this.onThemeChanged,
    required this.onNotificationsChanged,
    required this.onBiometricLoginChanged,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final rollCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();
  String error = "";
  final bool _isAuthenticating = false;

  @override
  void dispose() {
    rollCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  Future<bool> _authenticateWithBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      if (!canCheck || !isSupported) {
        setState(() {
          error =
              "Biometric login is enabled, but this device does not support it.";
        });
        return false;
      }

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: "Authenticate with fingerprint/biometric to continue",
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      if (!didAuthenticate) {
        setState(() {
          error = "Biometric authentication failed or was cancelled.";
        });
      }
      return didAuthenticate;
    } catch (_) {
      setState(() {
        error = "Unable to use biometric authentication on this device.";
      });
      return false;
    }
  }

  Future<void> login() async {

  final roll = rollCtrl.text.trim();
  final pass = passCtrl.text.trim();

  try {

    final doc = await FirebaseFirestore.instance
        .collection("students")
        .doc(roll)
        .get();

    if (!doc.exists) {

      setState(() {
        error = "Student not found";
      });

      return;
    }

    final data = doc.data()!;

    if (data["password"] != pass) {

      setState(() {
        error = "Invalid password";
      });

      return;
    }

    final student = Student.fromFirestore(
      roll: doc.id,
      data: data,
    );

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          student: student,
          settings: widget.settings,
          onThemeChanged: widget.onThemeChanged,
          onNotificationsChanged: widget.onNotificationsChanged,
          onBiometricLoginChanged: widget.onBiometricLoginChanged,
        ),
      ),
    );

  } catch (e) {

    setState(() {
      error = "Login error: $e";
    });

  }
}

  Future<bool> _hasActiveInternetConnection() async {
    final connectivity = Connectivity();
    final dynamic result = await connectivity.checkConnectivity();
    final hasTransport = switch (result) {
      ConnectivityResult singleResult => singleResult != ConnectivityResult.none,
      List<ConnectivityResult> listResult =>
        listResult.any((r) => r != ConnectivityResult.none),
      List listResult => listResult.any((r) => r != ConnectivityResult.none),
      _ => false,
    };
    if (!hasTransport) return false;

    try {
      final response = await http
          .get(Uri.parse("https://clients3.google.com/generate_204"))
          .timeout(const Duration(seconds: 4));
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF003366), Color(0xFF001F3F)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = constraints.maxWidth < 430
                  ? constraints.maxWidth - 32
                  : 400.0;
              return Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    24,
                    16,
                    24 + MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: cardWidth),
                    child: Card(
                      elevation: 10,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Central University of Jammu",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF003366),
                              ),
                            ),
                            const SizedBox(height: 40),
                            Image.asset(
                              'assets/images/CU_JAMMU-removebg-preview.png',
                              fit: BoxFit.cover,
                              width: constraints.maxWidth < 360 ? 110 : 144,
                              height: constraints.maxWidth < 360 ? 100 : 140,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.school, size: 80),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: rollCtrl,
                              decoration: const InputDecoration(
                                labelText: "Enrollment Number",
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: passCtrl,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: "Password",
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isAuthenticating ? null : login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF003366),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  _isAuthenticating
                                      ? "Signing in..."
                                      : "Login",
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const RoleLoginScreen(
                                        role: DashboardRole.admin,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.admin_panel_settings),
                                label: const Text("Admin Login"),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF003366),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  side: const BorderSide(
                                    color: Color(0xFF003366),
                                    width: 1.2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const RoleLoginScreen(
                                        role: DashboardRole.authority,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.shield_outlined),
                                label: const Text("Authority Login"),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF003366),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  side: const BorderSide(
                                    color: Color(0xFF003366),
                                    width: 1.2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "if your name is Kush Kumar then your password will be KushKumar123",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 4, 83, 7),
                              ),
                            ),
                            if (error.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  error,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
