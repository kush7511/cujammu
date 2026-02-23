import 'package:cuj/screens/in_app_webview_page.dart';
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Opening Library...")),
          );
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Opening Exams...")),
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
        : items.where((item) => item.title.toLowerCase().contains(query)).toList();
    final suggestions = query.isEmpty
        ? <_DashboardItem>[]
        : items
            .where((item) => item.title.toLowerCase().contains(query))
            .take(5)
            .toList();

    return Padding(
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
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}