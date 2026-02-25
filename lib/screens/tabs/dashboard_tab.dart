import 'package:cuj/screens/in_app_webview_page.dart';
import 'package:cuj/screens/chatbot/cuj_chatbot_sheet.dart';
import 'package:cuj/screens/timetable_page.dart';
import 'package:cuj/screens/transport_page.dart';
import 'package:flutter/material.dart';
import '../../data/student_db.dart';

class DashboardTab extends StatefulWidget {
  final Student student;
  const DashboardTab({super.key, required this.student});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
              TextField(
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

class _ExamCenterPage extends StatelessWidget {
  final Student student;

  const _ExamCenterPage({required this.student});

  @override
  Widget build(BuildContext context) {
    final upcomingExams = <Map<String, String>>[
      {
        "subject": "Software Engineering",
        "date": "15 Apr 2026",
        "time": "10:00 AM - 1:00 PM",
        "venue": "Block A, Room 204",
      },
      {
        "subject": "DBMS",
        "date": "18 Apr 2026",
        "time": "2:00 PM - 5:00 PM",
        "venue": "Block B, Room 110",
      },
      {
        "subject": "Operating Systems",
        "date": "22 Apr 2026",
        "time": "10:00 AM - 1:00 PM",
        "venue": "Block C, Room 303",
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
                label: "Result Portal",
                icon: Icons.assessment,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Open Results tab from the side menu."),
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
