import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum DashboardRole { admin, authority }

const Color _brandBlue = Color(0xFF003366);
const Color _brandBlueLight = Color(0xFF0B4A8B);
const Color _textDark = Color(0xFF0F172A);

class RoleLoginScreen extends StatefulWidget {
  final DashboardRole role;

  const RoleLoginScreen({super.key, required this.role});

  @override
  State<RoleLoginScreen> createState() => _RoleLoginScreenState();
}

class _RoleLoginScreenState extends State<RoleLoginScreen> {
  final TextEditingController _idCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String _error = "";

  static const String _adminId = "admin";
  static const String _adminPassword = "admin@cuj123";
  static const String _authorityId = "authority";
  static const String _authorityPassword = "authority@cuj123";

  bool get _isAdmin => widget.role == DashboardRole.admin;
  String get _roleTitle => _isAdmin ? "Admin Login" : "Authority Login";

  @override
  void dispose() {
    _idCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = "";
    });

    final id = _idCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final valid = _isAdmin
        ? (id == _adminId && password == _adminPassword)
        : (id == _authorityId && password == _authorityPassword);

    if (!mounted) return;
    if (!valid) {
      setState(() {
        _loading = false;
        _error = "Invalid credentials for ${_roleTitle.toLowerCase()}.";
      });
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => AdminDashboard(role: widget.role)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _textDark,
        title: Text(
          _roleTitle,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: _PageBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _HeroCard(
                        title: _roleTitle,
                        subtitle: _isAdmin
                            ? "Control complete app activity."
                            : "Manage operations quickly.",
                        icon: _isAdmin
                            ? Icons.admin_panel_settings_rounded
                            : Icons.shield_rounded,
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _idCtrl,
                        decoration: _fieldDecoration(
                          "User ID",
                          Icons.badge_outlined,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _passwordCtrl,
                        obscureText: _obscure,
                        decoration: _fieldDecoration(
                          "Password",
                          Icons.lock_outline,
                          suffix: IconButton(
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _loading ? null : _login,
                          style: FilledButton.styleFrom(
                            backgroundColor: _brandBlue,
                          ),
                          child: Text(_loading ? "Signing in..." : "Sign In"),
                        ),
                      ),
                      if (_error.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _error,
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

  InputDecoration _fieldDecoration(
    String label,
    IconData icon, {
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF8FBFF),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class AdminDashboard extends StatelessWidget {
  final DashboardRole role;
  const AdminDashboard({super.key, required this.role});

  bool get _isAdmin => role == DashboardRole.admin;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _isAdmin ? 5 : 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F8FC),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: _textDark,
          title: Text(
            _isAdmin ? "Admin Panel" : "Authority Panel",
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          actions: [
            IconButton(
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              icon: const Icon(Icons.logout_rounded),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            labelColor: _brandBlue,
            tabs: [
              const Tab(text: "Overview"),
              const Tab(text: "Complaints"),
              const Tab(text: "Leave"),
              const Tab(text: "Tech Support"),
              if (_isAdmin) const Tab(text: "Firebase Data"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OverviewTab(role: role),
            _ComplaintManagerTab(role: role),
            _LeaveManagerTab(role: role),
            _TechSupportManagerTab(role: role),
            if (_isAdmin) const _FirebaseCollectionsTab(),
          ],
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final DashboardRole role;
  const _OverviewTab({required this.role});

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == DashboardRole.admin;
    return _PageBackground(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HeroCard(
            title: isAdmin
                ? "Central Admin Operations"
                : "Authority Operations",
            subtitle: isAdmin
                ? "Manage complaints, leave, support tickets and Firebase data."
                : "Review and update student requests from one panel.",
            icon: isAdmin
                ? Icons.admin_panel_settings_rounded
                : Icons.shield_rounded,
          ),
          const SizedBox(height: 10),
          _CollectionCountCard(
            collectionName: "hostel_complaints",
            title: "Hostel Complaints",
            icon: Icons.report_problem_outlined,
            color: Colors.orange,
          ),
          _CollectionCountCard(
            collectionName: "hostel_leave_applications",
            title: "Leave Applications",
            icon: Icons.event_note_outlined,
            color: Colors.green,
          ),
          _CollectionCountCard(
            collectionName: "tech_support_tickets",
            title: "Tech Support Tickets",
            icon: Icons.support_agent_outlined,
            color: Colors.indigo,
          ),
        ],
      ),
    );
  }
}

class _CollectionCountCard extends StatelessWidget {
  final String collectionName;
  final String title;
  final IconData icon;
  final Color color;

  const _CollectionCountCard({
    required this.collectionName,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection(collectionName).snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.14),
              child: Icon(icon, color: color),
            ),
            title: Text(title),
            subtitle: Text("Total records: $count"),
          ),
        );
      },
    );
  }
}

class _ComplaintManagerTab extends StatefulWidget {
  final DashboardRole role;
  const _ComplaintManagerTab({required this.role});

  @override
  State<_ComplaintManagerTab> createState() => _ComplaintManagerTabState();
}

class _ComplaintManagerTabState extends State<_ComplaintManagerTab> {
  String _statusFilter = "All";
  static const List<String> _statusOptions = [
    "Pending",
    "In Progress",
    "Resolved",
    "Rejected",
  ];

  Future<void> _updateStatus(
    DocumentReference<Map<String, dynamic>> ref,
    String nextStatus,
  ) async {
    await ref.update({
      "status": nextStatus,
      "updatedAt": FieldValue.serverTimestamp(),
      "updatedByRole": widget.role == DashboardRole.admin
          ? "admin"
          : "authority",
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Complaint status updated to $nextStatus")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _PageBackground(
      child: Column(
        children: [
          const SizedBox(height: 12),
          _FilterCard(
            value: _statusFilter,
            items: const [
              "All",
              "Pending",
              "In Progress",
              "Resolved",
              "Rejected",
            ],
            label: "Complaint Status",
            onChanged: (value) => setState(() => _statusFilter = value),
          ),
          Expanded(
            child: _RecordsList(
              collection: "hostel_complaints",
              statusFilter: _statusFilter,
              itemBuilder: (doc) {
                final data = doc.data();
                return _RecordCard(
                  icon: Icons.report_problem_outlined,
                  iconColor: Colors.orange,
                  title: data["category"] as String? ?? "Complaint",
                  subtitle:
                      "${data["studentName"] ?? ""} (${data["rollNumber"] ?? ""})\n"
                      "Block: ${data["block"] ?? "N/A"}\n"
                      "${data["description"] ?? ""}",
                  status: data["status"] as String? ?? "Pending",
                  menuItems: _statusOptions,
                  onMenuSelected: (value) =>
                      _updateStatus(doc.reference, value),
                );
              },
              emptyText: "No complaints found.",
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaveManagerTab extends StatefulWidget {
  final DashboardRole role;
  const _LeaveManagerTab({required this.role});

  @override
  State<_LeaveManagerTab> createState() => _LeaveManagerTabState();
}

class _LeaveManagerTabState extends State<_LeaveManagerTab> {
  String _statusFilter = "All";
  static const List<String> _statusOptions = [
    "Pending",
    "Approved",
    "Rejected",
  ];

  Future<void> _updateStatus(
    DocumentReference<Map<String, dynamic>> ref,
    String nextStatus,
  ) async {
    await ref.update({
      "status": nextStatus,
      "updatedAt": FieldValue.serverTimestamp(),
      "updatedByRole": widget.role == DashboardRole.admin
          ? "admin"
          : "authority",
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Leave status updated to $nextStatus")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _PageBackground(
      child: Column(
        children: [
          const SizedBox(height: 12),
          _FilterCard(
            value: _statusFilter,
            items: const ["All", "Pending", "Approved", "Rejected"],
            label: "Leave Status",
            onChanged: (value) => setState(() => _statusFilter = value),
          ),
          Expanded(
            child: _RecordsList(
              collection: "hostel_leave_applications",
              statusFilter: _statusFilter,
              itemBuilder: (doc) {
                final data = doc.data();
                return _RecordCard(
                  icon: Icons.event_note_outlined,
                  iconColor: Colors.green,
                  title: data["leaveType"] as String? ?? "Leave",
                  subtitle:
                      "${data["studentName"] ?? ""} (${data["rollNumber"] ?? ""})\n"
                      "Block: ${data["block"] ?? "N/A"} | Room: ${data["roomNumber"] ?? "N/A"}\n"
                      "From: ${_formatTimestamp(data["fromDate"])} | To: ${_formatTimestamp(data["toDate"])}",
                  status: data["status"] as String? ?? "Pending",
                  menuItems: _statusOptions,
                  onMenuSelected: (value) =>
                      _updateStatus(doc.reference, value),
                );
              },
              emptyText: "No leave applications found.",
            ),
          ),
        ],
      ),
    );
  }
}

class _TechSupportManagerTab extends StatefulWidget {
  final DashboardRole role;
  const _TechSupportManagerTab({required this.role});

  @override
  State<_TechSupportManagerTab> createState() => _TechSupportManagerTabState();
}

class _TechSupportManagerTabState extends State<_TechSupportManagerTab> {
  String _statusFilter = "All";
  static const List<String> _statusOptions = [
    "Pending",
    "In Progress",
    "Resolved",
    "Rejected",
  ];

  Future<void> _updateStatus(
    DocumentReference<Map<String, dynamic>> ref,
    String nextStatus,
  ) async {
    await ref.update({
      "status": nextStatus,
      "updatedAt": FieldValue.serverTimestamp(),
      "updatedByRole": widget.role == DashboardRole.admin
          ? "admin"
          : "authority",
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Tech support status updated to $nextStatus")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _PageBackground(
      child: Column(
        children: [
          const SizedBox(height: 12),
          _FilterCard(
            value: _statusFilter,
            items: const [
              "All",
              "Pending",
              "In Progress",
              "Resolved",
              "Rejected",
            ],
            label: "Ticket Status",
            onChanged: (value) => setState(() => _statusFilter = value),
          ),
          Expanded(
            child: _RecordsList(
              collection: "tech_support_tickets",
              statusFilter: _statusFilter,
              itemBuilder: (doc) {
                final data = doc.data();
                return _RecordCard(
                  icon: Icons.support_agent_outlined,
                  iconColor: Colors.indigo,
                  title: data["subject"] as String? ?? "Support Ticket",
                  subtitle:
                      "Ticket: ${data["ticketId"] ?? "-"}\n"
                      "${data["studentName"] ?? ""} (${data["enrollmentNumber"] ?? ""})\n"
                      "${data["description"] ?? ""}",
                  status: data["status"] as String? ?? "Pending",
                  menuItems: _statusOptions,
                  onMenuSelected: (value) =>
                      _updateStatus(doc.reference, value),
                );
              },
              emptyText: "No tech support tickets found.",
            ),
          ),
        ],
      ),
    );
  }
}

class _FirebaseCollectionsTab extends StatelessWidget {
  const _FirebaseCollectionsTab();
  static const List<String> _collections = [
    "hostel_complaints",
    "hostel_leave_applications",
    "tech_support_tickets",
    "chat_conversations",
  ];

  @override
  Widget build(BuildContext context) {
    return _PageBackground(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _HeroCard(
            title: "Firebase Data Control",
            subtitle:
                "Open collections, inspect records and manage data in UI.",
            icon: Icons.storage_rounded,
          ),
          const SizedBox(height: 10),
          ..._collections.map((collection) {
            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection(collection)
                  .snapshots(),
              builder: (context, snapshot) {
                final count = snapshot.data?.docs.length ?? 0;
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE8EEF6),
                      child: Icon(Icons.storage_outlined, color: _brandBlue),
                    ),
                    title: Text(collection),
                    subtitle: Text("Records: $count"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 15),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CollectionExplorerScreen(
                            collectionName: collection,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}

class CollectionExplorerScreen extends StatelessWidget {
  final String collectionName;
  const CollectionExplorerScreen({super.key, required this.collectionName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _textDark,
        title: Text("Collection: $collectionName"),
      ),
      body: _PageBackground(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection(collectionName)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return const Center(child: Text("No documents found."));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: docs.length,
              itemBuilder: (_, index) {
                final doc = docs[index];
                final data = doc.data();
                final preview = data.entries
                    .take(3)
                    .map((e) => "${e.key}: ${e.value}")
                    .join("\n");
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    title: Text("Doc ID: ${doc.id}"),
                    subtitle: Text(preview.isEmpty ? "No fields" : preview),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () async {
                        await doc.reference.delete();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Document deleted")),
                        );
                      },
                    ),
                    onTap: () => _showDocumentDetails(context, doc.id, data),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _showDocumentDetails(
    BuildContext context,
    String id,
    Map<String, dynamic> data,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Document $id"),
        content: SizedBox(
          width: 450,
          child: SingleChildScrollView(
            child: Text(
              data.entries.map((e) => "${e.key}: ${e.value}").join("\n\n"),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}

class _RecordsList extends StatelessWidget {
  final String collection;
  final String statusFilter;
  final Widget Function(QueryDocumentSnapshot<Map<String, dynamic>> doc)
  itemBuilder;
  final String emptyText;

  const _RecordsList({
    required this.collection,
    required this.statusFilter,
    required this.itemBuilder,
    required this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection(collection)
          .orderBy("createdAt", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        final docs = snapshot.data?.docs ?? [];
        final filtered = statusFilter == "All"
            ? docs
            : docs
                  .where(
                    (doc) =>
                        (doc.data()["status"] as String? ?? "Pending").trim() ==
                        statusFilter,
                  )
                  .toList();
        if (filtered.isEmpty) {
          return Center(child: Text(emptyText));
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
          itemCount: filtered.length,
          itemBuilder: (_, index) => itemBuilder(filtered[index]),
        );
      },
    );
  }
}

class _FilterCard extends StatelessWidget {
  final String value;
  final List<String> items;
  final String label;
  final ValueChanged<String> onChanged;

  const _FilterCard({
    required this.value,
    required this.items,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: DropdownButtonFormField<String>(
            initialValue: value,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (next) {
              if (next == null) return;
              onChanged(next);
            },
          ),
        ),
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String status;
  final List<String> menuItems;
  final ValueChanged<String> onMenuSelected;

  const _RecordCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.menuItems,
    required this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
        leading: CircleAvatar(
          backgroundColor: iconColor.withValues(alpha: 0.15),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(subtitle),
              const SizedBox(height: 6),
              _StatusBadge(status: status),
            ],
          ),
        ),
        isThreeLine: false,
        trailing: PopupMenuButton<String>(
          onSelected: onMenuSelected,
          itemBuilder: (_) => menuItems
              .map((s) => PopupMenuItem(value: s, child: Text(s)))
              .toList(),
          child: const Icon(Icons.more_vert),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const _HeroCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [_brandBlue, _brandBlueLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _brandBlue.withValues(alpha: 0.24),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PageBackground extends StatelessWidget {
  final Widget child;
  const _PageBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF8FBFF), Color(0xFFF1F5FA)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;
    if (status == "Pending") color = Colors.orange;
    if (status == "In Progress") color = Colors.blue;
    if (status == "Resolved" || status == "Approved") color = Colors.green;
    if (status == "Rejected") color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String _formatTimestamp(dynamic value) {
  if (value == null) return "-";
  DateTime? date;
  if (value is Timestamp) {
    date = value.toDate();
  } else if (value is DateTime) {
    date = value;
  } else if (value is String) {
    date = DateTime.tryParse(value);
  }
  if (date == null) return value.toString();
  final d = date.day.toString().padLeft(2, "0");
  final m = date.month.toString().padLeft(2, "0");
  final h = date.hour.toString().padLeft(2, "0");
  final min = date.minute.toString().padLeft(2, "0");
  return "$d/$m/${date.year} $h:$min";
}
