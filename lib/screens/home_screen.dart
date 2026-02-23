import 'package:cuj/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
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

  final tabs = [
    "Attendance",
    "Dashboard",
    "Results",
    "Profile",
    "Help",
    "Settings",
    "Logout",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tabs[index])),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(backgroundImage: AssetImage('assets/images/profile_picture.png', 
            ), 
            radius: 40,
            ),
              accountName: Text(widget.student.name),
              accountEmail: Text(widget.student.roll),
            ),
             ListTile(
              title: const Text("Attendance"),
              onTap: () => setState(() => index = 0),
              leading: const Icon(Icons.calendar_month),
            ),
             ListTile(
              title: const Text("Dashboard"),
              onTap: () => setState(() => index = 1),
              leading: const Icon(Icons.dashboard),
            ),
            ListTile(
              title: const Text("Results"),
              onTap: () => setState(() => index = 2),
              leading: const Icon(Icons.assessment),
            ),
            ListTile(
              title: const Text("Profile"),
              onTap: () => setState(() => index = 3),
              leading: const Icon(Icons.person),
            ),
             ListTile(
              title: const Text("Help"),
              onTap: ()=> setState(()=> index = 4),
              leading: const Icon(Icons.help),
            ),
            ListTile(
              title: const Text("Settings"),
              onTap: ()=> setState(()=> index = 5),
              leading: const Icon(Icons.settings),
            ),
            ListTile(
              title: const Text("Logout"),
              onTap: ()=> setState(()=> index = 6),
              leading: const Icon(Icons.logout),
            ),
            
          ],
        ),
      ),
      body: IndexedStack(
        index: index,
        children: [
          AttendanceTab(student: widget.student),
          DashboardTab(student: widget.student),
          ResultsTab(student: widget.student),
          ProfileTab(student: widget.student),
          HelpTab(student: widget.student),
          SettingsTab(
            settings: widget.settings,
            onThemeChanged: widget.onThemeChanged,
            onNotificationsChanged: widget.onNotificationsChanged,
            onBiometricLoginChanged: widget.onBiometricLoginChanged,
          ),
          LogoutTab(
            student: widget.student,
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
            content: Text("Biometric authentication is not available on this device."),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Biometric login enabled.")),
      );
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
                const SnackBar(content: Text("Privacy policy page coming soon")),
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
            subtitle: Text("1.0.0"),
          ),
        ),
      ],
    );
  }
}
class ProfileTab extends StatelessWidget {
  final Student student;
  const ProfileTab({super.key, required this.student});

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
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // Profile Image
              CircleAvatar(
                backgroundImage:
                    const AssetImage('assets/images/profile_picture.png'),
                radius: 80,
              ),

              const SizedBox(height: 30),

              // Profile Info Cards
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(student.name),
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
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
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
                  MaterialPageRoute(
                    builder: (context) => const FAQPage(),
                  ),
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
                  MaterialPageRoute(
                    builder: (context) => ComplaintPage(),
                  ),
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
          "https://www.google.com/maps/search/?api=1&query=Central+University+of+Jammu");

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
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
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
