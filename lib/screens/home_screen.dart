import 'package:cuj/screens/login_screen.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:local_auth/local_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/student_db.dart';
import '../services/app_settings_service.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/results_tab.dart';
import 'tabs/attendance_tab.dart';
import 'tabs/ComplainPage.dart';
import 'tabs/FAQPage.dart';

class HomeScreen extends StatefulWidget {
  final Student student;
  final AppSettings settings;
  final ValueChanged<bool> onThemeChanged;
  final ValueChanged<bool> onNotificationsChanged;
  final ValueChanged<bool> onBiometricLoginChanged;

  const HomeScreen({
    super.key,
    required this.student,
    required this.settings,
    required this.onThemeChanged,
    required this.onNotificationsChanged,
    required this.onBiometricLoginChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;
  late Student _student;

  final tabs = [
    "Dashboard",
    "Profile",
    "Attendance",
    "Results",
    "Settings",
    "Help",
    "Logout",
  ];

  @override
  void initState() {
    super.initState();
    _student = widget.student;
  }

  void _selectTab(int newIndex) {
    setState(() => index = newIndex);
    Navigator.of(context).pop();
  }

  void _onStudentUpdated(Student updated) {
    setState(() {
      _student = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tabs[index])),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: _StudentAvatar(
                student: _student,
                radius: 40,
              ),
              accountName: Text(_student.name),
              accountEmail: Text(_student.roll),
            ),
            ListTile(
              title: const Text("Dashboard"),
              onTap: () => _selectTab(0),
              leading: const Icon(Icons.dashboard),
            ),
            ListTile(
              title: const Text("Profile"),
              onTap: () => _selectTab(1),
              leading: const Icon(Icons.person),
            ),
            ListTile(
              title: const Text("Attendance"),
              onTap: () => _selectTab(2),
              leading: const Icon(Icons.calendar_month),
            ),
            ListTile(
              title: const Text("Results"),
              onTap: () => _selectTab(3),
              leading: const Icon(Icons.assessment),
            ),
            ListTile(
              title: const Text("Settings"),
              onTap: () => _selectTab(4),
              leading: const Icon(Icons.settings),
            ),
            ListTile(
              title: const Text("Help"),
              onTap: () => _selectTab(5),
              leading: const Icon(Icons.help),
            ),
            ListTile(
              title: const Text("Logout"),
              onTap: () => _selectTab(6),
              leading: const Icon(Icons.logout),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: index,
        children: [
          DashboardTab(student: _student),
          ProfileTab(student: _student, onStudentUpdated: _onStudentUpdated),
          AttendanceTab(student: _student),
          ResultsTab(student: _student),
          SettingsTab(
            settings: widget.settings,
            onThemeChanged: widget.onThemeChanged,
            onNotificationsChanged: widget.onNotificationsChanged,
            onBiometricLoginChanged: widget.onBiometricLoginChanged,
          ),
          HelpTab(student: widget.student),
          LogoutTab(
            student: _student,
            settings: widget.settings,
            onThemeChanged: widget.onThemeChanged,
            onNotificationsChanged: widget.onNotificationsChanged,
            onBiometricLoginChanged: widget.onBiometricLoginChanged,
          ),
        ],
      ),
    );
  }
}

class SettingsTab extends StatefulWidget {
  final AppSettings settings;
  final ValueChanged<bool> onThemeChanged;
  final ValueChanged<bool> onNotificationsChanged;
  final ValueChanged<bool> onBiometricLoginChanged;

  const SettingsTab({
    super.key,
    required this.settings,
    required this.onThemeChanged,
    required this.onNotificationsChanged,
    required this.onBiometricLoginChanged,
  });

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<void> _setBiometricPreference(bool enabled) async {
    if (!enabled) {
      widget.onBiometricLoginChanged(false);
      return;
    }

    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      if (!canCheck || !isSupported) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Biometric authentication is not available on this device.",
            ),
          ),
        );
        return;
      }

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: "Confirm fingerprint/biometric setup for login",
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!mounted) return;

      if (!didAuthenticate) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Biometric setup was cancelled.")),
        );
        return;
      }

      widget.onBiometricLoginChanged(true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Biometric login enabled.")));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Unable to enable biometric login on this device."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "App Settings",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text("Dark Mode"),
            subtitle: const Text("Enable dark appearance across the app"),
            value: widget.settings.darkModeEnabled,
            onChanged: widget.onThemeChanged,
          ),
        ),
        Card(
          child: SwitchListTile(
            secondary: const Icon(Icons.notifications_active),
            title: const Text("Push Notifications"),
            subtitle: const Text("Receive important alerts and updates"),
            value: widget.settings.notificationsEnabled,
            onChanged: widget.onNotificationsChanged,
          ),
        ),
        Card(
          child: SwitchListTile(
            secondary: const Icon(Icons.fingerprint),
            title: const Text("Biometric Login"),
            subtitle: const Text("Use fingerprint/face unlock at sign in"),
            value: widget.settings.biometricLoginEnabled,
            onChanged: _setBiometricPreference,
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.language),
            title: const Text("Language"),
            subtitle: const Text("English"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Language settings coming soon")),
              );
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text("Privacy Policy"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Privacy policy page coming soon"),
                ),
              );
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text("Terms & Conditions"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Terms page coming soon")),
              );
            },
          ),
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.info_outline),
            title: Text("App Version"),
            subtitle: Text("1.0.0\nDeveloped by Kush Kumar"),
          ),
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.verified),
            title: Text("Developer"),
            subtitle: Text("Kush Kumar"),
          ),
        ),
      ],
    );
  }
}

class ProfileTab extends StatelessWidget {
  final Student student;
  final ValueChanged<Student> onStudentUpdated;

  const ProfileTab({
    super.key,
    required this.student,
    required this.onStudentUpdated,
  });

  Future<void> _pickAndSaveProfilePicture(
    BuildContext context,
    ImageSource source,
  ) async {
    final picker = ImagePicker();
    final selected = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    if (selected == null) return;

    final bytes = await selected.readAsBytes();
    final imageBase64 = _toCircularPngBase64(bytes);
    if (imageBase64 == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not process selected image.")),
      );
      return;
    }
    await updateStudentProfileImage(
      roll: student.roll,
      profileImageBase64: imageBase64,
    );
    final updated = studentDB[student.roll] ?? student;
    onStudentUpdated(updated);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile picture updated.")),
    );
  }

  Future<void> _removeProfilePicture(BuildContext context) async {
    await updateStudentProfileImage(
      roll: student.roll,
      profileImageBase64: null,
    );
    final updated = studentDB[student.roll] ?? student;
    onStudentUpdated(updated);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile picture reset to default.")),
    );
  }

  Future<void> _showProfilePhotoActions(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text("Take Photo"),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _pickAndSaveProfilePicture(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text("Choose from Gallery"),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _pickAndSaveProfilePicture(context, ImageSource.gallery);
                },
              ),
              if ((student.profileImageBase64 ?? "").trim().isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text("Remove Profile Picture"),
                  textColor: Colors.red,
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _removeProfilePicture(context);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text("Cancel"),
                onTap: () => Navigator.pop(sheetContext),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _toCircularPngBase64(Uint8List sourceBytes) {
    final decoded = img.decodeImage(sourceBytes);
    if (decoded == null) return null;

    final shortestSide = decoded.width < decoded.height
        ? decoded.width
        : decoded.height;
    final offsetX = (decoded.width - shortestSide) ~/ 2;
    final offsetY = (decoded.height - shortestSide) ~/ 2;
    final square = img.copyCrop(
      decoded,
      x: offsetX,
      y: offsetY,
      width: shortestSide,
      height: shortestSide,
    );
    final resized = img.copyResize(square, width: 512, height: 512);
    final radius = resized.width / 2;

    for (var y = 0; y < resized.height; y++) {
      for (var x = 0; x < resized.width; x++) {
        final dx = x - radius;
        final dy = y - radius;
        final isOutsideCircle = (dx * dx + dy * dy) > (radius * radius);
        if (isOutsideCircle) {
          resized.setPixelRgba(x, y, 0, 0, 0, 0);
        }
      }
    }

    return base64Encode(img.encodePng(resized));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Title
              const Text(
                "Student Profile",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // Profile Image
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  _StudentAvatar(student: student, radius: 80),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF003366),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      onPressed: () => _showProfilePhotoActions(context),
                      icon: const Icon(Icons.edit, color: Colors.white),
                      tooltip: "Edit profile picture",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Profile Info Cards
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    children: [
                      Text(student.name),
                      if (isProtectedStudentRoll(student.roll))
                        const Icon(
                          Icons.verified,
                          color: Color(0xFF1976D2),
                          size: 20,
                        ),
                    ],
                  ),
                  subtitle: Text("Course: ${student.course}"),
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.family_restroom),
                  title: const Text("Father's Name"),
                  trailing: Text(student.fname),
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text("Phone Number"),
                  trailing: Text(student.pnumber.toString()),
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.cake),
                  title: const Text("Date of Birth"),
                  trailing: Text(student.dob.toString()),
                ),
              ),

              const Divider(height: 40),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.school),
                  title: const Text("Course"),
                  subtitle: Text(student.course),
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.numbers),
                  title: const Text("Enrollment Number"),
                  subtitle: Text(student.roll),
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.grade),
                  title: const Text("CGPA"),
                  subtitle: const Text("6.1"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentAvatar extends StatelessWidget {
  final Student student;
  final double radius;

  const _StudentAvatar({required this.student, required this.radius});

  Color _backgroundColorFromName(String name) {
    const palette = <Color>[
      Color(0xFFE3F2FD),
      Color(0xFFE8F5E9),
      Color(0xFFFFF8E1),
      Color(0xFFF3E5F5),
      Color(0xFFFFEBEE),
      Color(0xFFE0F7FA),
      Color(0xFFF1F8E9),
    ];
    final hash = name.trim().toLowerCase().hashCode;
    return palette[hash.abs() % palette.length];
  }

  String _initialsFromName(String name) {
    final parts = name
        .trim()
        .split(RegExp(r"\s+"))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return "ST";
    if (parts.length == 1) {
      final word = parts.first;
      final first = word.substring(0, 1).toUpperCase();
      if (word.length == 1) return "$first$first";
      final second = word.substring(1, 2).toUpperCase();
      return "$first$second";
    }
    final first = parts.first.substring(0, 1).toUpperCase();
    final surnameFirst = parts.last.substring(0, 1).toUpperCase();
    return "$first$surnameFirst";
  }

  @override
  Widget build(BuildContext context) {
    final encoded = student.profileImageBase64;
    if (encoded != null && encoded.trim().isNotEmpty) {
      try {
        return CircleAvatar(
          radius: radius,
          backgroundImage: MemoryImage(base64Decode(encoded)),
        );
      } catch (_) {
        // Fall through to initials avatar when image data is invalid.
      }
    }

    if (student.roll == protectedDeveloperRoll) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: const AssetImage("assets/images/profile_picture.png"),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: _backgroundColorFromName(student.name),
      child: Text(
        _initialsFromName(student.name),
        style: TextStyle(
          color: const Color(0xFF003366),
          fontSize: radius * 0.48,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class HelpTab extends StatelessWidget {
  const HelpTab({super.key, required Student student});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Help & Support",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          // Contact Office
          Card(
            child: ListTile(
              leading: const Icon(Icons.call, color: Colors.blue),
              title: const Text("Contact College Office"),
              subtitle: const Text("Call administration department"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Calling College Office...")),
                );
              },
            ),
          ),

          // Email Support
          Card(
            child: ListTile(
              leading: const Icon(Icons.email, color: Colors.orange),
              title: const Text("Email Support"),
              subtitle: const Text("registrar@cujammu.ac.in"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Opening Email...")),
                );
              },
            ),
          ),

          // FAQs
          Card(
            child: ListTile(
              leading: const Icon(Icons.question_answer, color: Colors.green),
              title: const Text("FAQs"),
              subtitle: const Text("Frequently Asked Questions"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FAQPage()),
                );
              },
            ),
          ),

          // Raise Complaint
          Card(
            child: ListTile(
              leading: const Icon(Icons.report_problem, color: Colors.red),
              title: const Text("Raise a Complaint"),
              subtitle: const Text("Report academic or technical issues"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ComplaintPage()),
                );
              },
            ),
          ),

          // Technical Support
          Card(
            child: ListTile(
              leading: const Icon(Icons.settings, color: Colors.purple),
              title: const Text("Technical Support"),
              subtitle: const Text("App related problems"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Contacting Technical Team...")),
                );
              },
            ),
          ),

          // Campus Location
          Card(
            child: ListTile(
              leading: const Icon(Icons.location_on, color: Colors.red),
              title: const Text("Central University of Jammu"),
              subtitle: const Text("Bagla, Rahya-Suchani, Jammu & Kashmir"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                final Uri url = Uri.parse(
                  "https://www.google.com/maps/search/?api=1&query=Central+University+of+Jammu",
                );

                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

//logout tab start here.....
class LogoutTab extends StatelessWidget {
  final Student student;
  final AppSettings settings;
  final ValueChanged<bool> onThemeChanged;
  final ValueChanged<bool> onNotificationsChanged;
  final ValueChanged<bool> onBiometricLoginChanged;

  const LogoutTab({
    super.key,
    required this.student,
    required this.settings,
    required this.onThemeChanged,
    required this.onNotificationsChanged,
    required this.onBiometricLoginChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.logout_rounded,
              size: 80,
              color: Color(0xFF003366),
            ),
            const SizedBox(height: 20),
            const Text(
              "Are you sure you want to logout?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => LoginScreen(
                        settings: settings,
                        onThemeChanged: onThemeChanged,
                        onNotificationsChanged: onNotificationsChanged,
                        onBiometricLoginChanged: onBiometricLoginChanged,
                      ),
                    ),
                  );
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.exit_to_app),
                    SizedBox(width: 10),
                    Text(
                      "LOGOUT",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
