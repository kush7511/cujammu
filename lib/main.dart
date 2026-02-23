import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/login_screen.dart';
import 'services/app_settings_service.dart';

void main() {
  runApp(const CUJApp());
}

class CUJApp extends StatefulWidget {
  const CUJApp({super.key});

  @override
  State<CUJApp> createState() => _CUJAppState();
}

class _CUJAppState extends State<CUJApp> {
  AppSettings _settings = const AppSettings(
    darkModeEnabled: false,
    notificationsEnabled: true,
    biometricLoginEnabled: false,
  );
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final loadedSettings = await AppSettingsService.loadSettings();
      if (!mounted) return;
      setState(() {
        _settings = loadedSettings;
        _isLoading = false;
      });
    } on PlatformException {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateSettings(AppSettings updated) async {
    setState(() {
      _settings = updated;
    });
    await AppSettingsService.saveSettings(updated);
  }

  Future<void> _setDarkMode(bool enabled) async {
    await _updateSettings(_settings.copyWith(darkModeEnabled: enabled));
  }

  Future<void> _setNotificationsEnabled(bool enabled) async {
    await _updateSettings(_settings.copyWith(notificationsEnabled: enabled));
  }

  Future<void> _setBiometricLoginEnabled(bool enabled) async {
    await _updateSettings(_settings.copyWith(biometricLoginEnabled: enabled));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      title: 'CU Jammu',
      debugShowCheckedModeBanner: false,
      themeMode: _settings.darkModeEnabled ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        primaryColor: const Color(0xFF003366),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF003366),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF001A33),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),

      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Central University of Jammu - Student Portal"),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: CircleAvatar(
                  radius: 20,
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/CU_JAMMU-removebg-preview.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.school, size: 20),
                    ),
                  ),
                ),
                ),
            ],
          ),
          body: child,
        );
      },
      home: LoginScreen(
        settings: _settings,
        onThemeChanged: _setDarkMode,
        onNotificationsChanged: _setNotificationsEnabled,
        onBiometricLoginChanged: _setBiometricLoginEnabled,
      ),
    );
  }
}
