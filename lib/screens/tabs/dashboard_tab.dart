import 'dart:async';
import 'package:cuj/screens/admit_card_page.dart';
import 'package:cuj/screens/in_app_webview_page.dart';
import 'package:cuj/screens/hostel_block_auth_screen.dart';
import 'package:cuj/screens/chatbot/cuj_chatbot_sheet.dart';
import 'package:cuj/screens/timetable_page.dart';
import 'package:cuj/screens/transport_page.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../data/student_db.dart';
import '../../data/hostel_student_db.dart';
import '../../services/university_notification_service.dart';

class DashboardTab extends StatefulWidget {
  final Student student;
  const DashboardTab({super.key, required this.student});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final TextEditingController _searchController = TextEditingController();
  List<UniversityNotification> _notifications = [];
  StreamSubscription<List<UniversityNotification>>? _notificationsSub;

  bool get _hasUnreadNotifications =>
      _notifications.any((item) => !item.isRead);

  @override
  void initState() {
    super.initState();
    final service = UniversityNotificationService.instance;
    _notifications = service.notifications;
    _notificationsSub = service.notificationsStream.listen((items) {
      if (!mounted) return;
      setState(() {
        _notifications = items;
      });
    });
  }

  @override
  void dispose() {
    _notificationsSub?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openNotificationsSheet() async {
    await UniversityNotificationService.instance.markAllAsRead();
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.68,
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text(
                "University Notifications",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const Divider(height: 20),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _notifications.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final item = _notifications[index];
                    return ListTile(
                      leading: const Icon(
                        Icons.notifications_active_outlined,
                        color: Color(0xFF003366),
                      ),
                      title: Text(item.title),
                      subtitle: Text("${item.message}\n${_relativeTime(item.receivedAt)}"),
                      isThreeLine: true,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _relativeTime(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    return "${diff.inDays}d ago";
  }

  List<_DashboardItem> _dashboardItems(BuildContext context) {
    return [
      _DashboardItem(
        title: "Timetable",
        icon: Icons.calendar_today,
        color: Colors.blue,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TimetablePage()),
          );
        },
      ),
      _DashboardItem(
        title: "Assignments",
        icon: Icons.assignment,
        color: Colors.orange,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Opening Assignments...")),
          );
        },
      ),
      _DashboardItem(
        title: "Fee Payment",
        icon: Icons.account_balance_wallet,
        color: Colors.purple,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Opening Fee Payment...")),
          );
        },
      ),
      _DashboardItem(
        title: "Library",
        icon: Icons.menu_book,
        color: Colors.brown,
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Opening Library...")));
        },
      ),
      _DashboardItem(
        title: "Notices",
        icon: Icons.notifications,
        color: Colors.red,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const InAppWebViewPage(
                title: "Notices",
                url: "https://www.cujammu.ac.in/en/viewAllNotifications/",
              ),
            ),
          );
        },
      ),
      _DashboardItem(
        title: "Exams",
        icon: Icons.school,
        color: Colors.teal,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => _ExamCenterPage(student: widget.student),
            ),
          );
        },
      ),
      _DashboardItem(
        title: "Book E-Bus",
        icon: Icons.directions_bus,
        color: Colors.indigo,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TransportPage()),
          );
        },
      ),
      _DashboardItem(
        title: "Scholarships",
        icon: Icons.workspace_premium,
        color: Colors.green,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => _ScholarshipsPage(student: widget.student),
            ),
          );
        },
      ),
      _DashboardItem(
        title: "Hostel & Mess",
        icon: Icons.meeting_room,
        color: Colors.deepOrange,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const _HostelMessPage(),
            ),
          );
        },
      ),
      _DashboardItem(
        title: "Placement Cell",
        icon: Icons.business_center,
        color: Colors.deepPurple,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const InAppWebViewPage(
                title: "Placement Cell",
                url: "https://www.cujammu.ac.in/en/placements/",
              ),
            ),
          );
        },
      ),
      _DashboardItem(
        title: "Academic Calendar",
        icon: Icons.event_available,
        color: Colors.blueGrey,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const _AcademicCalendarPdfPage(),
            ),
          );
        },
      ),
      _DashboardItem(
        title: "Documents",
        icon: Icons.folder_shared,
        color: Colors.cyan,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => _DocumentsPage(student: widget.student),
            ),
          );
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final items = _dashboardItems(context);
    final query = _searchController.text.trim().toLowerCase();
    final filteredItems = query.isEmpty
        ? items
        : items
              .where((item) => item.title.toLowerCase().contains(query))
              .toList();
    final suggestions = query.isEmpty
        ? <_DashboardItem>[]
        : items
              .where((item) => item.title.toLowerCase().contains(query))
              .take(5)
              .toList();

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: "serach here",
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: query.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Material(
                        color: const Color(0xFFE8EEF5),
                        borderRadius: BorderRadius.circular(12),
                        child: IconButton(
                          tooltip: "Notifications",
                          onPressed: _openNotificationsSheet,
                          icon: const Icon(
                            Icons.notifications_none_rounded,
                            color: Color(0xFF003366),
                          ),
                        ),
                      ),
                      if (_hasUnreadNotifications)
                        const Positioned(
                          right: 6,
                          top: 6,
                          child: _NotificationDot(),
                        ),
                    ],
                  ),
                ],
              ),
              if (suggestions.isNotEmpty) ...[
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: suggestions
                        .map(
                          (item) => ListTile(
                            dense: true,
                            leading: Icon(item.icon, color: item.color),
                            title: Text(item.title),
                            onTap: () {
                              _searchController.text = item.title;
                              setState(() {});
                              item.onTap();
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Expanded(
                child: filteredItems.isEmpty
                    ? const Center(
                        child: Text(
                          "No dashboard items found",
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : GridView.count(
                        crossAxisCount: 3,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        children: filteredItems
                            .map(
                              (item) => DashboardCard(
                                title: item.title,
                                icon: item.icon,
                                color: item.color,
                                onTap: item.onTap,
                              ),
                            )
                            .toList(),
                      ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 18,
          bottom: 18,
          child: FloatingActionButton.extended(
            heroTag: "cuj_ai_chatbot",
            backgroundColor: const Color(0xFF003366),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.smart_toy_rounded),
            label: const Text("AI Help"),
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                builder: (_) =>
                    const SizedBox(height: 580, child: CujChatbotSheet()),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _NotificationDot extends StatelessWidget {
  const _NotificationDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _ExamCenterPage extends StatelessWidget {
  final Student student;

  const _ExamCenterPage({required this.student});

  @override
  Widget build(BuildContext context) {
    final upcomingExams = <Map<String, String>>[
      {
        "subject": "DBMS",
        "date": "15 Feb 2026",
        "time": "10:30 AM - 12:30 PM",
        "venue": "Fabricated Block, Room 1",
      },
      {
        "subject": "Machine Learning",
        "date": "15 Feb 2026",
        "time": "2:00 PM - 4:00 PM",
        "venue": "Fabricated Block, Room 1",
      },
      {
        "subject": "Operating Systems",
        "date": "16 Feb 2026",
        "time": "10:30 AM - 12:30 PM",
        "venue": "Fabricated Block, Room 1",
      },
      {
        "subject": "Software Engineering",
        "date": "16 Feb 2026",
        "time": "2:00 PM - 4:00 PM",
        "venue": "Fabricated Block, Room 1",
      },
      {
        "subject": "Digital Electronics",
        "date": "22 Feb 2026",
        "time": "10:30 AM - 12:30 PM",
        "venue": "Fabricated Block, Room 1",
      },
      {
        "subject": "java Programming",
        "date": "22 Feb 2026",
        "time": "2:00 PM - 4:00 PM",
        "venue": "Fabricated Block, Room 1",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Exams"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF0B5D73), Color(0xFF14889E)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "${student.roll} • ${student.course}",
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Track exam schedule, exam-day essentials, and result links from one place.",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Quick Actions",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ExamActionChip(
                label: "Exam Notifications",
                icon: Icons.notifications_active,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InAppWebViewPage(
                        title: "Exam Notifications",
                        url: "https://www.cujammu.ac.in/en/viewAllNotifications/",
                      ),
                    ),
                  );
                },
              ),
              _ExamActionChip(
                label: "Date Sheet",
                icon: Icons.event_note,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TimetablePage(),
                    ),
                  );
                },
              ),
              _ExamActionChip(
                label: "Admit Cards",
                 icon: Icons.menu_book_rounded,
                 onTap: () {
                          Navigator.push(
                          context,
                            MaterialPageRoute(
                                 builder: (_) => AdmitCardPage(student: student),
                            ),
                           );
                           },
                          ),
              _ExamActionChip(label: "Syllabus", 
              icon: Icons.menu_book, 
              onTap:() {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Opening Syllabus...")),
                );
              },
              ),
              _ExamActionChip(
                label: "Result Portal",
                icon: Icons.assessment,
                onTap: () {
                 Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InAppWebViewPage(
                        title: "Exam Results",
                        url: "https://www.cujammu.ac.in/en/Results/",
                      ),
                    ),
                  );
                },
              ),
              _ExamActionChip(
                label: "Exam Helpdesk",
                icon: Icons.support_agent,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "For support: registrar@cujammu.ac.in / exam section.",
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            "Upcoming Exams",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          const SizedBox(height: 10),
          ...upcomingExams.map(
            (exam) => Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE0F2F1),
                  child: Icon(Icons.school, color: Color(0xFF00695C)),
                ),
                title: Text(exam["subject"]!),
                subtitle: Text(
                  "${exam["date"]}\n${exam["time"]}\n${exam["venue"]}",
                ),
                isThreeLine: true,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            "Exam Day Checklist",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          const SizedBox(height: 10),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ChecklistLine(text: "Carry CUJ ID Card and hall ticket."),
                  _ChecklistLine(text: "Reach exam hall at least 30 minutes early."),
                  _ChecklistLine(text: "Carry blue/black pen and required stationery."),
                  _ChecklistLine(text: "Electronic gadgets are not allowed unless permitted."),
                  _ChecklistLine(text: "Verify subject code before starting the paper."),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            "Recent Performance",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("CGPA", style: TextStyle(color: Colors.black54)),
                      Text(
                        student.cgpa.toStringAsFixed(1),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Subjects Evaluated",
                        style: TextStyle(color: Colors.black54),
                      ),
                      Text(
                        "${student.results.length}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ExamActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: const Color(0xFF00695C)),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: const Color(0xFFE0F2F1),
      side: BorderSide(color: Colors.teal.shade200),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );
  }
}

class _ChecklistLine extends StatelessWidget {
  final String text;

  const _ChecklistLine({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.check_circle, size: 16, color: Color(0xFF2E7D32)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _ScholarshipsPage extends StatelessWidget {
  final Student student;

  const _ScholarshipsPage({required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scholarships")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: Text(student.name),
              subtitle: Text("${student.roll} - ${student.course}"),
            ),
          ),
          const SizedBox(height: 10),
          const Card(
            child: ListTile(
              leading: Icon(Icons.check_circle_outline, color: Colors.green),
              title: Text("National Scholarship Portal"),
              subtitle: Text(
                "Track government scholarship notifications and deadlines.",
              ),
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.account_balance, color: Colors.indigo),
              title: Text("State Scholarships"),
              subtitle: Text(
                "Apply for Jammu & Kashmir and other state funding schemes.",
              ),
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.rule_folder_outlined, color: Colors.orange),
              title: Text("Eligibility Checklist"),
              subtitle: Text(
                "Keep caste/income certificates, mark sheets, and bank details ready.",
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HostelMessPage extends StatelessWidget {
  const _HostelMessPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hostel & Mess")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            "Hostel Blocks",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          _HostelBlockTile(
            name: "SPM Boys Hostel",
            subtitle: "Boys Hostel Block",
            icon: Icons.apartment_rounded,
            backgroundColor: Color(0xFFE3F2FD),
            iconColor: Color(0xFF1565C0),
            hostelBlock: HostelBlock.spmBoys,
          ),
          SizedBox(height: 10),
          _HostelBlockTile(
            name: "BRS Boys Hostel",
            subtitle: "Boys Hostel Block",
            icon: Icons.home_work_rounded,
            backgroundColor: Color(0xFFE8F5E9),
            iconColor: Color(0xFF2E7D32),
            hostelBlock: HostelBlock.brsBoys,
          ),
          SizedBox(height: 10),
          _HostelBlockTile(
            name: "Shailputri Girls Hostel",
            subtitle: "Girls Hostel Block",
            icon: Icons.house_rounded,
            backgroundColor: Color(0xFFFCE4EC),
            iconColor: Color(0xFFAD1457),
            hostelBlock: HostelBlock.shailputriGirls,
          ),
          SizedBox(height: 12),
          Text(
            "Mess Services",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: Icon(Icons.restaurant_menu, color: Colors.teal),
              title: Text("Mess Menu"),
              subtitle: Text(
                "Check breakfast/lunch/dinner schedule and special meal notices.",
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.report_gmailerrorred, color: Colors.red),
              title: Text("Hostel Complaint"),
              subtitle: Text(
                "Use Help section to submit water, electricity, or sanitation issues.",
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HostelBlockTile extends StatelessWidget {
  final String name;
  final String subtitle;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final HostelBlock hostelBlock;

  const _HostelBlockTile({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.hostelBlock,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HostelBlockAuthScreen(hostelBlock: hostelBlock),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 108),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}

// ignore: unused_element
class _PlacementCellPage extends StatelessWidget {
  final Student student;

  const _PlacementCellPage({required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Placement Cell")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_pin_circle_outlined),
              title: const Text("Current Profile"),
              subtitle: Text(
                "${student.name}\nCGPA: ${student.cgpa.toStringAsFixed(1)}",
              ),
              isThreeLine: true,
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.work_outline, color: Colors.deepPurple),
              title: Text("Internship Updates"),
              subtitle: Text(
                "Track internship opportunities and application timelines.",
              ),
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.groups_2_outlined, color: Colors.blue),
              title: Text("Campus Drives"),
              subtitle: Text(
                "View upcoming company drives, eligibility and venue details.",
              ),
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.description_outlined, color: Colors.brown),
              title: Text("Resume Checklist"),
              subtitle: Text(
                "Keep updated resume, projects, certificates and coding profiles ready.",
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AcademicCalendarPdfPage extends StatelessWidget {
  const _AcademicCalendarPdfPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Academic Calendar")),
      body: SfPdfViewer.asset("assets/pdfs/2026.pdf"),
    );
  }
}

class _DocumentsPage extends StatefulWidget {
  final Student student;

  const _DocumentsPage({required this.student});

  @override
  State<_DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<_DocumentsPage> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final ImagePicker _picker = ImagePicker();
  final List<_SecureDocument> _documents = [];
  bool _loading = true;
  bool _unlocked = false;

  String get _storageKey => "secure_documents_${widget.student.roll}";

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadDocuments();
    await _unlockVault();
    if (!mounted) return;
    setState(() {
      _loading = false;
    });
  }

  Future<void> _loadDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.trim().isEmpty) return;
    try {
      final parsed = jsonDecode(raw);
      if (parsed is! List) return;
      _documents
        ..clear()
        ..addAll(
          parsed
              .whereType<Map>()
              .map(
                (e) => _SecureDocument.fromJson(Map<String, dynamic>.from(e)),
              ),
        );
    } catch (_) {
      // Ignore malformed persisted data.
    }
  }

  Future<void> _saveDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(_documents.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> _unlockVault() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final supported = await _localAuth.isDeviceSupported();
      if (!canCheck || !supported) {
        _unlocked = true;
        return;
      }
      _unlocked = await _localAuth.authenticate(
        localizedReason: "Authenticate to access secure university documents",
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      _unlocked = false;
    }
  }

  Future<void> _addDocument() async {
    final titleCtrl = TextEditingController();
    String category = "Marksheet";
    ImageSource source = ImageSource.gallery;
    bool saving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (_, setDialogState) {
            return AlertDialog(
              title: const Text("Add Document"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: "Document Title",
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: "Category"),
                    items: const [
                      DropdownMenuItem(
                        value: "Marksheet",
                        child: Text("Marksheet"),
                      ),
                      DropdownMenuItem(value: "ID Card", child: Text("ID Card")),
                      DropdownMenuItem(
                        value: "Certificate",
                        child: Text("Certificate"),
                      ),
                      DropdownMenuItem(
                        value: "Fee Receipt",
                        child: Text("Fee Receipt"),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() {
                        category = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<ImageSource>(
                    initialValue: source,
                    decoration: const InputDecoration(labelText: "Source"),
                    items: const [
                      DropdownMenuItem(
                        value: ImageSource.gallery,
                        child: Text("Gallery"),
                      ),
                      DropdownMenuItem(
                        value: ImageSource.camera,
                        child: Text("Camera"),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() {
                        source = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: saving ? null : () => Navigator.pop(dialogContext),
                  child: const Text("Cancel"),
                ),
                FilledButton(
                  onPressed: saving
                      ? null
                      : () async {
                          final title = titleCtrl.text.trim();
                          if (title.isEmpty) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text("Document title is required."),
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            saving = true;
                          });
                          final selected = await _picker.pickImage(
                            source: source,
                            maxWidth: 1400,
                            maxHeight: 1400,
                            imageQuality: 85,
                          );
                          if (selected == null) {
                            if (dialogContext.mounted) {
                              setDialogState(() {
                                saving = false;
                              });
                            }
                            return;
                          }

                          final bytes = await selected.readAsBytes();
                          _documents.insert(
                            0,
                            _SecureDocument(
                              id: DateTime.now().microsecondsSinceEpoch.toString(),
                              title: title,
                              category: category,
                              imageBase64: base64Encode(bytes),
                              uploadedOn: DateTime.now(),
                            ),
                          );
                          await _saveDocuments();
                          if (!mounted) return;
                          setState(() {});
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                        },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );

    titleCtrl.dispose();
  }

  String _date(DateTime d) =>
      "${d.day.toString().padLeft(2, "0")}/${d.month.toString().padLeft(2, "0")}/${d.year}";

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_unlocked) {
      return Scaffold(
        appBar: AppBar(title: const Text("Documents")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock, size: 64, color: Color(0xFF003366)),
                const SizedBox(height: 12),
                const Text(
                  "Secure Document Vault Locked",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Authenticate to access university documents.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () async {
                    await _unlockVault();
                    if (!mounted) return;
                    setState(() {});
                  },
                  icon: const Icon(Icons.fingerprint),
                  label: const Text("Unlock"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Documents")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addDocument,
        icon: const Icon(Icons.add),
        label: const Text("Add Document"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.security_outlined, color: Colors.green),
              title: const Text("Secure University Document Vault"),
              subtitle: Text(
                "${widget.student.name}\n${widget.student.roll}\n"
                "Store important university documents in one protected place.",
              ),
              isThreeLine: true,
            ),
          ),
          const SizedBox(height: 8),
          if (_documents.isEmpty)
            const Card(
              child: ListTile(
                leading: Icon(Icons.folder_open_outlined),
                title: Text("No saved documents"),
                subtitle: Text(
                  "Tap 'Add Document' to upload marksheets, ID cards, certificates, and receipts.",
                ),
              ),
            )
          else
            ..._documents.map((doc) {
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(doc.title),
                  subtitle: Text("${doc.category} • ${_date(doc.uploadedOn)}"),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == "view") {
                        await showDialog<void>(
                          context: context,
                          builder: (_) => Dialog(
                            child: InteractiveViewer(
                              child: Image.memory(base64Decode(doc.imageBase64)),
                            ),
                          ),
                        );
                      }
                      if (value == "delete") {
                        _documents.removeWhere((e) => e.id == doc.id);
                        await _saveDocuments();
                        if (!mounted) return;
                        setState(() {});
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: "view", child: Text("View")),
                      PopupMenuItem(value: "delete", child: Text("Delete")),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _SecureDocument {
  final String id;
  final String title;
  final String category;
  final String imageBase64;
  final DateTime uploadedOn;

  const _SecureDocument({
    required this.id,
    required this.title,
    required this.category,
    required this.imageBase64,
    required this.uploadedOn,
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "category": category,
    "imageBase64": imageBase64,
    "uploadedOn": uploadedOn.toIso8601String(),
  };

  factory _SecureDocument.fromJson(Map<String, dynamic> json) {
    return _SecureDocument(
      id: json["id"] as String,
      title: json["title"] as String,
      category: json["category"] as String,
      imageBase64: json["imageBase64"] as String,
      uploadedOn: DateTime.parse(json["uploadedOn"] as String),
    );
  }
}

class _DashboardItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const DashboardCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color,
              child: Icon(icon, size: 30, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
