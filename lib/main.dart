import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'data/student_db.dart';
import 'services/app_settings_service.dart';
import 'services/university_notification_service.dart';
import 'services/session_service.dart';
import 'firebase_options.dart'; // Ensure this file contains DefaultFirebaseOptions

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await UniversityNotificationService.instance.initialize();
  await UniversityNotificationService.instance.storeRemoteMessage(message);
}
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(
    _firebaseMessagingBackgroundHandler,
  );

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
  Student? _loggedInStudent;
  bool _isLoading = true;
  bool _splashDone = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _initializeNotifications();
  }
  Future<void> _initializeNotifications() async {
    await UniversityNotificationService.instance.initialize();
  }

  Future<void> _initializeApp() async {
    try {
      await loadRegisteredStudents();
      final loadedSettings = await AppSettingsService.loadSettings();
      final savedRoll = await SessionService.getLoggedInRoll();
      final savedStudent = savedRoll == null ? null : studentDB[savedRoll];
      if (!mounted) return;
      setState(() {
        _settings = loadedSettings;
        _loggedInStudent = savedStudent;
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
    return FutureBuilder(
  future: Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (snapshot.hasError) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              "Firebase Error: ${snapshot.error}",
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'CU Jammu',
      debugShowCheckedModeBanner: false,
      themeMode:
          _settings.darkModeEnabled ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        primaryColor: const Color(0xFF003366),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: !_splashDone
          ? _WelcomeSplashScreen(
              onCompleted: () {
                if (!mounted) return;
                setState(() {
                  _splashDone = true;
                });
              },
            )
          : _isLoading
              ? const _InitialLoadingScreen()
              : (_loggedInStudent != null
                    ? HomeScreen(
                        student: _loggedInStudent!,
                        settings: _settings,
                        onThemeChanged: _setDarkMode,
                        onNotificationsChanged: _setNotificationsEnabled,
                        onBiometricLoginChanged: _setBiometricLoginEnabled,
                      )
                    : LoginScreen(
                        settings: _settings,
                        onThemeChanged: _setDarkMode,
                        onNotificationsChanged: _setNotificationsEnabled,
                        onBiometricLoginChanged: _setBiometricLoginEnabled,
                      )),
    );
  },
);
  }
}

class _InitialLoadingScreen extends StatelessWidget {
  const _InitialLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _WelcomeSplashScreen extends StatefulWidget {
  final VoidCallback onCompleted;

  const _WelcomeSplashScreen({required this.onCompleted});

  @override
  State<_WelcomeSplashScreen> createState() => _WelcomeSplashScreenState();
}

class _WelcomeSplashScreenState extends State<_WelcomeSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _textOpacity;
  Timer? _finishTimer;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _logoScale = Tween<double>(
      begin: 0.45,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _logoOpacity = Tween<double>(
      begin: 0.2,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.25, 1)),
    );
    _textOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.25, 1)),
    );
    _controller.forward();
    _finishTimer = Timer(const Duration(milliseconds: 2500), () {
      if (!mounted || _completed) return;
      _completed = true;
      widget.onCompleted();
    });
  }

  @override
  void dispose() {
    _finishTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF003366), Color(0xFF001F3F)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Opacity(
                      opacity: _logoOpacity.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: Container(
                          width: 150,
                          height: 150,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.22),
                                blurRadius: 18,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/CU_JAMMU-removebg-preview.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.school, size: 72),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    SlideTransition(
                      position: _textSlide,
                      child: FadeTransition(
                        opacity: _textOpacity,
                        child: const Text(
                          "Welcome to CU Jammu",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeTransition(
                      opacity: _textOpacity,
                      child: const Text(
                        "नमस्ते | ਸਤਿ ਸ਼੍ਰੀ ਅਕਾਲ | Hello",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
