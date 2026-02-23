import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../data/student_db.dart';
import 'home_screen.dart';
import '../services/app_settings_service.dart';

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
  bool _isAuthenticating = false;

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
    if (_isAuthenticating) return;

    final roll = rollCtrl.text.trim();
    final pass = passCtrl.text.trim();

    if (studentDB.containsKey(roll) &&
        studentDB[roll]!.password == pass) {
      if (widget.settings.biometricLoginEnabled) {
        setState(() {
          _isAuthenticating = true;
          error = "";
        });
        final passed = await _authenticateWithBiometrics();
        if (!mounted) return;
        setState(() {
          _isAuthenticating = false;
        });
        if (!passed) {
          return;
        }
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            student: studentDB[roll]!,
            settings: widget.settings,
            onThemeChanged: widget.onThemeChanged,
            onNotificationsChanged: widget.onNotificationsChanged,
            onBiometricLoginChanged: widget.onBiometricLoginChanged,
          ),
        ),
      );
    } else {
      setState(() => error = "Invalid Enrollment Number or Password");
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Card(
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: 320,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Central University of Jammu",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF003366),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Image.asset(
                        'assets/images/CU_JAMMU-removebg-preview.png',
                        fit: BoxFit.cover,
                        width: 150,
                        height: 130,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.school, size: 80),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: rollCtrl,
                        decoration: const InputDecoration(
                          labelText: "Enrollment Number",
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: passCtrl,
                        obscureText: true,
                        decoration:
                            const InputDecoration(labelText: "Password"),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _isAuthenticating ? null : login,
                        child: Text(_isAuthenticating ? "Authenticating..." : "Login"),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "if your name is Kush Kumar then your password will be KushKumar123",
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
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
