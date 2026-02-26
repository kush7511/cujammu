import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/hostel_student_db.dart';

class HostelBlockAuthScreen extends StatefulWidget {
  final HostelBlock hostelBlock;

  const HostelBlockAuthScreen({super.key, required this.hostelBlock});

  @override
  State<HostelBlockAuthScreen> createState() => _HostelBlockAuthScreenState();
}

class _HostelBlockAuthScreenState extends State<HostelBlockAuthScreen> {
  final TextEditingController _enrollmentCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  bool _loading = true;
  bool _obscurePassword = true;
  String _error = "";

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await loadHostelDatabases();
    if (!mounted) return;
    setState(() {
      _loading = false;
    });
  }

  @override
  void dispose() {
    _enrollmentCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _login() {
    final student = authenticateHostelStudent(
      block: widget.hostelBlock,
      enrollmentNumber: _enrollmentCtrl.text,
      password: _passwordCtrl.text,
    );
    if (student == null) {
      setState(() {
        _error = "Invalid enrollment number or password.";
      });
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HostelBlockHomeScreen(
          hostelBlock: widget.hostelBlock,
          student: student,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.hostelBlock.displayName),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hostelBlock.displayName),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFFEDF3FA), const Color(0xFFDDE8F4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFF003366),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.meeting_room_rounded,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        widget.hostelBlock.displayName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF003366),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Hostel Student Login",
                        style: TextStyle(
                          color: Color(0xFF607D8B),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 22),
                      TextField(
                        controller: _enrollmentCtrl,
                        decoration: InputDecoration(
                          labelText: "Enrollment Number",
                          prefixIcon: const Icon(Icons.badge_outlined),
                          filled: true,
                          fillColor: const Color(0xFFF7FAFE),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF7FAFE),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _login,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF003366),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Sign In",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      if (_error.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            _error,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      const SizedBox(height: 8),
                      const Text(
                        "Use your hostel-issued credentials.",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF78909C),
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

class HostelBlockHomeScreen extends StatefulWidget {
  final HostelBlock hostelBlock;
  final HostelStudent student;

  const HostelBlockHomeScreen({
    super.key,
    required this.hostelBlock,
    required this.student,
  });

  @override
  State<HostelBlockHomeScreen> createState() => _HostelBlockHomeScreenState();
}

class _HostelBlockHomeScreenState extends State<HostelBlockHomeScreen> {
  int _selectedIndex = 0;
  late HostelStudent _student;

  @override
  void initState() {
    super.initState();
    _student = widget.student;
  }

  List<Widget> _screens() {
    return [
      _HostelHomeTab(student: _student),
      _HostelComplainTab(
        student: _student,
        hostelBlock: widget.hostelBlock,
        onStudentUpdated: (updated) {
          setState(() {
            _student = updated;
          });
        },
      ),
      _HostelLeaveTab(
        student: _student,
        hostelBlock: widget.hostelBlock,
        onStudentUpdated: (updated) {
          setState(() {
            _student = updated;
          });
        },
      ),
      _HostelProfileTab(
        student: _student,
        hostelBlock: widget.hostelBlock,
        onStudentUpdated: (updated) {
          setState(() {
            _student = updated;
          });
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hostelBlock.displayName),
        centerTitle: true,
      ),
      body: _screens()[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem_outlined),
            activeIcon: Icon(Icons.report_problem),
            label: "Complain",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_available_outlined),
            activeIcon: Icon(Icons.event_available),
            label: "Leave Management",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

class _HostelHomeTab extends StatelessWidget {
  final HostelStudent student;

  const _HostelHomeTab({required this.student});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 10),
        const Text(
          "Hostel Dashboard",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: const [
            _HostelQuickTile(
              title: "Mess Menu",
              icon: Icons.restaurant_menu,
              color: Color(0xFF0B5ED7),
            ),
            _HostelQuickTile(
              title: "Fee Status",
              icon: Icons.account_balance_wallet_outlined,
              color: Color(0xFFEF6C00),
            ),
            _HostelQuickTile(
              title: "Notices",
              icon: Icons.campaign_outlined,
              color: Color(0xFF1565C0),
            ),
            _HostelQuickTile(
              title: "Emergency",
              icon: Icons.emergency_outlined,
              color: Color(0xFFAD1457),
            ),
          ],
        ),
      ],
    );
  }
}

class _HostelQuickTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _HostelQuickTile({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$title module coming soon.")),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HostelComplainTab extends StatefulWidget {
  final HostelStudent student;
  final HostelBlock hostelBlock;
  final ValueChanged<HostelStudent> onStudentUpdated;

  const _HostelComplainTab({
    required this.student,
    required this.hostelBlock,
    required this.onStudentUpdated,
  });

  @override
  State<_HostelComplainTab> createState() => _HostelComplainTabState();
}

class _HostelComplainTabState extends State<_HostelComplainTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _detailsCtrl = TextEditingController();
  bool _submitting = false;
  String _category = "Electricity";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _detailsCtrl.dispose();
    super.dispose();
  }

  String _dateText(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  Future<void> _submitComplaint() async {
    if (_submitting) return;
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    setState(() {
      _submitting = true;
    });

    final updated = await submitHostelComplaint(
      block: widget.hostelBlock,
      enrollmentNumber: widget.student.enrollmentNumber,
      complaint: HostelComplaint(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        category: _category,
        details: _detailsCtrl.text.trim(),
        reportedOn: DateTime.now(),
        status: "Pending",
      ),
    );

    if (!mounted) return;
    setState(() {
      _submitting = false;
    });
    if (updated == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to submit complaint.")),
      );
      return;
    }
    widget.onStudentUpdated(updated);
    _formKey.currentState?.reset();
    setState(() {
      _category = "Electricity";
      _detailsCtrl.clear();
    });
    _tabController.animateTo(1);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Complaint submitted.")));
  }

  @override
  Widget build(BuildContext context) {
    final complaints = widget.student.complaints;
    return Column(
      children: [
        Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                icon: Icon(Icons.edit_note_outlined),
                text: "Raise Complaint",
              ),
              Tab(
                icon: Icon(Icons.track_changes_outlined),
                text: "Track Status",
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: _category,
                          decoration: const InputDecoration(
                            labelText: "Complaint Category",
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: "Electricity",
                              child: Text("Electricity"),
                            ),
                            DropdownMenuItem(value: "Water", child: Text("Water")),
                            DropdownMenuItem(value: "WiFi", child: Text("WiFi")),
                            DropdownMenuItem(
                              value: "Sanitation",
                              child: Text("Sanitation"),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _category = value;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _detailsCtrl,
                          minLines: 3,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: "Describe the issue",
                            border: OutlineInputBorder(),
                            hintText:
                                "Write room/block details and issue description.",
                          ),
                          validator: (value) => value == null || value.trim().isEmpty
                              ? "Complaint details are required"
                              : null,
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _submitting ? null : _submitComplaint,
                            icon: const Icon(Icons.send_outlined),
                            label: Text(
                              _submitting
                                  ? "Submitting..."
                                  : "Submit Complaint",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              complaints.isEmpty
                  ? const Center(
                      child: Text(
                        "No complaints submitted yet.",
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: complaints.length,
                      itemBuilder: (_, index) {
                        final complaint = complaints[index];
                        final solved = complaint.status.toLowerCase() == "solved";
                        return Card(
                          child: ListTile(
                            leading: Icon(
                              solved ? Icons.check_circle : Icons.hourglass_top,
                              color: solved ? Colors.green : Colors.orange,
                            ),
                            title: Text(complaint.category),
                            subtitle: Text(
                              "${complaint.details}\n"
                              "Reported: ${_dateText(complaint.reportedOn)}\n"
                              "Status: ${complaint.status}",
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HostelLeaveTab extends StatefulWidget {
  final HostelStudent student;
  final HostelBlock hostelBlock;
  final ValueChanged<HostelStudent> onStudentUpdated;

  const _HostelLeaveTab({
    required this.student,
    required this.hostelBlock,
    required this.onStudentUpdated,
  });

  @override
  State<_HostelLeaveTab> createState() => _HostelLeaveTabState();
}

class _HostelLeaveTabState extends State<_HostelLeaveTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _reasonCtrl = TextEditingController();
  final _destinationCtrl = TextEditingController();
  final _guardianCtrl = TextEditingController();
  final _emergencyCtrl = TextEditingController();
  String _leaveType = "Day Leave";
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reasonCtrl.dispose();
    _destinationCtrl.dispose();
    _guardianCtrl.dispose();
    _emergencyCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isFromDate}) async {
    final initial = isFromDate
        ? (_fromDate ?? DateTime.now())
        : (_toDate ?? _fromDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      if (isFromDate) {
        _fromDate = picked;
        if (_toDate != null && _toDate!.isBefore(picked)) {
          _toDate = picked;
        }
      } else {
        _toDate = picked;
      }
    });
  }

  String _dateText(DateTime? date) {
    if (date == null) return "Select Date";
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  Future<void> _submitLeave() async {
    if (_submitting) return;
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    if (_fromDate == null || _toDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select from and to dates.")),
      );
      return;
    }
    if (_toDate!.isBefore(_fromDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("To date cannot be before from date.")),
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    final application = HostelLeaveApplication(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      leaveType: _leaveType,
      fromDate: _fromDate!,
      toDate: _toDate!,
      reason: _reasonCtrl.text.trim(),
      destination: _destinationCtrl.text.trim(),
      guardianContact: _guardianCtrl.text.trim(),
      emergencyContact: _emergencyCtrl.text.trim(),
      appliedOn: DateTime.now(),
      status: "Pending",
    );

    final updated = await submitHostelLeaveApplication(
      block: widget.hostelBlock,
      enrollmentNumber: widget.student.enrollmentNumber,
      application: application,
    );

    if (!mounted) return;
    setState(() {
      _submitting = false;
    });

    if (updated == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to submit leave application.")),
      );
      return;
    }

    widget.onStudentUpdated(updated);
    _formKey.currentState?.reset();
    setState(() {
      _leaveType = "Day Leave";
      _fromDate = null;
      _toDate = null;
      _reasonCtrl.clear();
      _destinationCtrl.clear();
      _guardianCtrl.clear();
      _emergencyCtrl.clear();
    });
    _tabController.animateTo(1);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Leave application submitted.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final leaves = widget.student.leaveApplications;
    return Column(
      children: [
        Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                icon: Icon(Icons.assignment_turned_in_outlined),
                text: "Apply for Leave",
              ),
              Tab(
                icon: Icon(Icons.history_toggle_off_outlined),
                text: "Leave History",
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: _leaveType,
                          decoration: const InputDecoration(
                            labelText: "Leave Type",
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: "Day Leave",
                              child: Text("Day Leave"),
                            ),
                            DropdownMenuItem(
                              value: "Overnight Leave",
                              child: Text("Overnight Leave"),
                            ),
                            DropdownMenuItem(
                              value: "Medical Leave",
                              child: Text("Medical Leave"),
                            ),
                            DropdownMenuItem(
                              value: "Emergency Leave",
                              child: Text("Emergency Leave"),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _leaveType = value;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _pickDate(isFromDate: true),
                                icon: const Icon(Icons.event_available_outlined),
                                label: Text("From: ${_dateText(_fromDate)}"),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _pickDate(isFromDate: false),
                                icon: const Icon(Icons.event_outlined),
                                label: Text("To: ${_dateText(_toDate)}"),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _reasonCtrl,
                          minLines: 2,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: "Reason for Leave",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value == null || value.trim().isEmpty
                              ? "Reason is required"
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _destinationCtrl,
                          decoration: const InputDecoration(
                            labelText: "Destination / Address During Leave",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value == null || value.trim().isEmpty
                              ? "Destination is required"
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _guardianCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: "Parent/Guardian Contact Number",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value == null || value.trim().isEmpty
                              ? "Guardian contact is required"
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _emergencyCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: "Emergency Contact Number",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value == null || value.trim().isEmpty
                              ? "Emergency contact is required"
                              : null,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _submitting ? null : _submitLeave,
                            icon: const Icon(Icons.send_outlined),
                            label: Text(
                              _submitting
                                  ? "Submitting..."
                                  : "Submit Leave Application",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              leaves.isEmpty
                  ? const Center(
                      child: Text(
                        "No leave applications found.",
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: leaves.length,
                      itemBuilder: (_, index) {
                        final leave = leaves[index];
                        return Card(
                          child: ListTile(
                            leading: Icon(
                              leave.status == "Approved"
                                  ? Icons.check_circle
                                  : leave.status == "Rejected"
                                      ? Icons.cancel
                                      : Icons.hourglass_top,
                              color: leave.status == "Approved"
                                  ? Colors.green
                                  : leave.status == "Rejected"
                                      ? Colors.red
                                      : Colors.orange,
                            ),
                            title: Text(leave.leaveType),
                            subtitle: Text(
                              "${_dateText(leave.fromDate)} - ${_dateText(leave.toDate)}\n"
                              "Status: ${leave.status}\n"
                              "Reason: ${leave.reason}",
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HostelProfileTab extends StatefulWidget {
  final HostelStudent student;
  final HostelBlock hostelBlock;
  final ValueChanged<HostelStudent> onStudentUpdated;

  const _HostelProfileTab({
    required this.student,
    required this.hostelBlock,
    required this.onStudentUpdated,
  });

  @override
  State<_HostelProfileTab> createState() => _HostelProfileTabState();
}

class _HostelProfileTabState extends State<_HostelProfileTab> {
  bool _updatingPhoto = false;

  Future<void> _pickAndSaveProfilePhoto(ImageSource source) async {
    if (_updatingPhoto) return;
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    if (file == null) return;

    setState(() {
      _updatingPhoto = true;
    });

    final bytes = await file.readAsBytes();
    final updated = await updateHostelStudentProfileImage(
      block: widget.hostelBlock,
      enrollmentNumber: widget.student.enrollmentNumber,
      profileImageBase64: base64Encode(bytes),
    );

    if (!mounted) return;
    setState(() {
      _updatingPhoto = false;
    });
    if (updated == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to update profile picture.")),
      );
      return;
    }
    widget.onStudentUpdated(updated);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Profile picture updated.")));
  }

  Future<void> _removeProfilePhoto() async {
    if (_updatingPhoto) return;
    setState(() {
      _updatingPhoto = true;
    });
    final updated = await updateHostelStudentProfileImage(
      block: widget.hostelBlock,
      enrollmentNumber: widget.student.enrollmentNumber,
      profileImageBase64: null,
    );
    if (!mounted) return;
    setState(() {
      _updatingPhoto = false;
    });
    if (updated == null) return;
    widget.onStudentUpdated(updated);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Profile picture removed.")));
  }

  Future<void> _showPhotoOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text("Take Photo"),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _pickAndSaveProfilePhoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text("Choose from Gallery"),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _pickAndSaveProfilePhoto(ImageSource.gallery);
                },
              ),
              if ((widget.student.profileImageBase64 ?? "").trim().isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text("Remove Photo"),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _removeProfilePhoto();
                  },
                ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text("Cancel"),
                onTap: () => Navigator.pop(sheetContext),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileAvatar() {
    final encoded = widget.student.profileImageBase64;
    if (encoded != null && encoded.trim().isNotEmpty) {
      try {
        return CircleAvatar(
          radius: 60,
          backgroundImage: MemoryImage(base64Decode(encoded)),
        );
      } catch (_) {
        // Fallback to initials below.
      }
    }

    final parts = widget.student.name
        .trim()
        .split(RegExp(r"\s+"))
        .where((e) => e.isNotEmpty)
        .toList();
    final initials = parts.isEmpty
        ? "HS"
        : parts.length == 1
            ? parts.first.substring(0, 1).toUpperCase()
            : "${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}"
                  .toUpperCase();

    return CircleAvatar(
      radius: 60,
      backgroundColor: const Color(0xFFE3F2FD),
      child: Text(
        initials,
        style: const TextStyle(
          color: Color(0xFF003366),
          fontSize: 34,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 6),
        Center(
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              _buildProfileAvatar(),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF003366),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  onPressed: _updatingPhoto ? null : _showPhotoOptions,
                  icon: _updatingPhoto
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.edit, color: Colors.white),
                  tooltip: "Edit profile picture",
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: ListTile(
            leading: const Icon(Icons.person),
            title: Text(widget.student.name),
            subtitle: Text(widget.student.enrollmentNumber),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.meeting_room_outlined),
            title: const Text("Hostel Room"),
            subtitle: Text(widget.student.roomNumber),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.family_restroom_outlined),
            title: const Text("Father Name"),
            subtitle: Text(widget.student.fatherName),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.call_outlined),
            title: const Text("Phone Number"),
            subtitle: Text(widget.student.phoneNumber),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.mail_outline),
            title: const Text("Email"),
            subtitle: Text(widget.student.email),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.school_outlined),
            title: const Text("Department"),
            subtitle: Text(widget.student.department),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.calendar_today_outlined),
            title: const Text("Academic Year"),
            subtitle: Text(widget.student.academicYear),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.support_agent_outlined),
            title: const Text("Guardian Contact"),
            subtitle: Text(widget.student.guardianContact),
          ),
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    HostelBlockAuthScreen(hostelBlock: widget.hostelBlock),
              ),
            );
          },
          icon: const Icon(Icons.logout),
          label: const Text("Logout"),
        ),
      ],
    );
  }
}
