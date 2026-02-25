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
  bool _isLoadingStudents = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    await loadRegisteredStudents();
    if (!mounted) return;
    setState(() {
      _isLoadingStudents = false;
    });
  }

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
    if (_isAuthenticating || _isLoadingStudents) return;

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

  Future<void> _openRegistrationScreen() async {
    final registered = await Navigator.push<_RegisteredCredentials>(
      context,
      MaterialPageRoute(
        builder: (_) => const _NewStudentRegistrationScreen(),
      ),
    );
    if (!mounted || registered == null) return;
    setState(() {
      rollCtrl.text = registered.roll;
      passCtrl.text = registered.password;
      error = "";
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Account created successfully. You can login now."),
      ),
    );
  }

  Future<void> _showDeleteAccountDialog() async {
    final formKey = GlobalKey<FormState>();
    final deleteRollCtrl = TextEditingController();
    final deletePassCtrl = TextEditingController();
    var deleting = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Delete Student Account"),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Enter enrollment number and password to permanently delete this account.",
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: deleteRollCtrl,
                      decoration: const InputDecoration(
                        labelText: "Enrollment Number",
                      ),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? "Enrollment number is required"
                          : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: deletePassCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: "Password"),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? "Password is required"
                          : null,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: deleting ? null : () => Navigator.pop(dialogContext),
                  child: const Text("Cancel"),
                ),
                FilledButton(
                  onPressed: deleting
                      ? null
                      : () async {
                          final form = formKey.currentState;
                          if (form == null || !form.validate()) return;
                          setDialogState(() {
                            deleting = true;
                          });

                          final roll = deleteRollCtrl.text.trim();
                          final pass = deletePassCtrl.text.trim();
                          final err = await deleteStudentAccount(
                            roll: roll,
                            password: pass,
                          );

                          if (!dialogContext.mounted) return;
                          setDialogState(() {
                            deleting = false;
                          });

                          if (err != null) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(content: Text(err)),
                            );
                            return;
                          }

                          if (rollCtrl.text.trim() == roll) {
                            rollCtrl.clear();
                            passCtrl.clear();
                          }
                          if (!mounted) return;
                          Navigator.pop(dialogContext);
                          setState(() {
                            error = "";
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Student account deleted successfully."),
                            ),
                          );
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(deleting ? "Deleting..." : "Delete"),
                ),
              ],
            );
          },
        );
      },
    );

    deleteRollCtrl.dispose();
    deletePassCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingStudents) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  _isAuthenticating
                                      ? "Authenticating..."
                                      : "Login",
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: _openRegistrationScreen,
                                  icon: const Icon(Icons.person_add_alt_1),
                                  label: const Text("Create New Account"),
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
                            ),
                            TextButton.icon(
                              onPressed: _showDeleteAccountDialog,
                              icon: const Icon(Icons.delete_outline),
                              label: const Text("Delete Account"),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red.shade700,
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

class _RegisteredCredentials {
  final String roll;
  final String password;

  const _RegisteredCredentials({required this.roll, required this.password});
}

class _NewStudentRegistrationScreen extends StatefulWidget {
  const _NewStudentRegistrationScreen();

  @override
  State<_NewStudentRegistrationScreen> createState() =>
      _NewStudentRegistrationScreenState();
}

class _NewStudentRegistrationScreenState
    extends State<_NewStudentRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rollCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _fnameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _courseCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  DateTime? _selectedDob;
  bool _creating = false;

  @override
  void dispose() {
    _rollCtrl.dispose();
    _nameCtrl.dispose();
    _fnameCtrl.dispose();
    _phoneCtrl.dispose();
    _courseCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2005, 1, 1),
      firstDate: DateTime(1980, 1, 1),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() {
      _selectedDob = picked;
    });
  }

  Future<void> _createAccount() async {
    if (_creating) return;
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    if (_selectedDob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Date of birth is required.")),
      );
      return;
    }

    setState(() {
      _creating = true;
    });

    final err = await registerStudent(
      roll: _rollCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      fname: _fnameCtrl.text.trim(),
      pnumber: int.parse(_phoneCtrl.text.trim()),
      dob: _selectedDob!,
      course: _courseCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() {
      _creating = false;
    });

    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }

    Navigator.pop(
      context,
      _RegisteredCredentials(
        roll: _rollCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      ),
    );
  }

  String _dobText() {
    if (_selectedDob == null) return "Select date of birth";
    return "${_selectedDob!.day}/${_selectedDob!.month}/${_selectedDob!.year}";
  }

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF003366), width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Student Registration")),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE9F0F8), Color(0xFFF7FAFD)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final contentMaxWidth = constraints.maxWidth < 600 ? 520.0 : 640.0;
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  16 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentMaxWidth),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    backgroundColor: Color(0xFF003366),
                                    child: Icon(
                                      Icons.person_add,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      "Create your CUJ student account to login quickly.",
                                      style: TextStyle(
                                        color: Colors.grey.shade800,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _rollCtrl,
                            textCapitalization: TextCapitalization.characters,
                            decoration: _fieldDecoration(
                              label: "Enrollment Number",
                              icon: Icons.badge_outlined,
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? "Enrollment number is required"
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _nameCtrl,
                            decoration: _fieldDecoration(
                              label: "Student Name",
                              icon: Icons.person_outline,
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? "Name is required"
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _fnameCtrl,
                            decoration: _fieldDecoration(
                              label: "Father Name",
                              icon: Icons.family_restroom_outlined,
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? "Father name is required"
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: _fieldDecoration(
                              label: "Phone Number",
                              icon: Icons.call_outlined,
                            ),
                            validator: (value) {
                              final text = value?.trim() ?? "";
                              if (text.isEmpty) return "Phone number is required";
                              if (int.tryParse(text) == null) {
                                return "Enter valid digits only";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: _pickDob,
                            borderRadius: BorderRadius.circular(12),
                            child: InputDecorator(
                              decoration: _fieldDecoration(
                                label: "Date of Birth",
                                icon: Icons.cake_outlined,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    _dobText(),
                                    style: TextStyle(
                                      color: _selectedDob == null
                                          ? Colors.grey.shade700
                                          : Colors.black87,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.calendar_today, size: 18),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _courseCtrl,
                            decoration: _fieldDecoration(
                              label: "Course",
                              icon: Icons.school_outlined,
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? "Course is required"
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: true,
                            decoration: _fieldDecoration(
                              label: "Create Password",
                              icon: Icons.lock_outline,
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? "Password is required"
                                : null,
                          ),
                          const SizedBox(height: 18),
                          FilledButton.icon(
                            onPressed: _creating ? null : _createAccount,
                            icon: const Icon(Icons.check_circle_outline),
                            label: Text(
                              _creating ? "Creating..." : "Create Account",
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF003366),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
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
