import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math';


class TechSupport extends StatefulWidget {
  final String studentName;
  final String enrollmentNumber;

  const TechSupport({
    super.key,
    required this.studentName,
    required this.enrollmentNumber,
  });

  @override
  State<TechSupport> createState() => _TechSupportState();
}

class _TechSupportState extends State<TechSupport> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();

  String _category = "App Crash";
  bool _loading = false;
  Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case "pending":
      return Colors.orange;
    case "in progress":
      return Colors.blue;
    case "resolved":
      return Colors.green;
    case "rejected":
      return Colors.red;
    default:
      return Colors.grey;
  }
}


  String _generateTicketId() {
    final random = Random().nextInt(999);
    final now = DateTime.now();
    return "CUJ-TS-${now.year}${now.month}${now.day}-$random";
  }

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
    });

    try {
      final ticketId = _generateTicketId();

      await FirebaseFirestore.instance
          .collection("tech_support_tickets")
          .add({
        "ticketId": ticketId,
        "studentName": widget.studentName,
        "enrollmentNumber": widget.enrollmentNumber,
        "category": _category,
        "subject": _subjectCtrl.text.trim(),
        "description": _descriptionCtrl.text.trim(),
        "status": "Pending",
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Ticket Submitted Successfully! ID: $ticketId"),
        ),
      );

      _formKey.currentState!.reset();
      _subjectCtrl.clear();
      _descriptionCtrl.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting ticket: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }
Widget _buildTrackTickets() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection("tech_support_tickets")
        .where("enrollmentNumber",
            isEqualTo: widget.enrollmentNumber)
        .snapshots(),
    builder: (context, snapshot) {

      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
            child: CircularProgressIndicator());
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return const Center(
          child: Text("No tickets found."),
        );
      }

      final tickets = snapshot.data!.docs;

      return ListView.builder(
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          final data =
              tickets[index].data() as Map<String, dynamic>;
          final status = data["status"] ?? "Pending";

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text(data["subject"] ?? ""),
              subtitle: Text(
                  "Ticket ID: ${data["ticketId"]}"),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(status)
                      .withOpacity(0.15),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: _getStatusColor(status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
  Widget _buildSupportForm() {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Form(
      key: _formKey,
      child: Column(
        children: [
          const Icon(Icons.support_agent,
              size: 60, color: Color(0xFF003366)),
          const SizedBox(height: 20),

          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(
              labelText: "Issue Category",
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                  value: "App Crash", child: Text("App Crash")),
              DropdownMenuItem(
                  value: "Login Problem",
                  child: Text("Login Problem")),
              DropdownMenuItem(
                  value: "Notification Issue",
                  child: Text("Notification Issue")),
              DropdownMenuItem(
                  value: "UI Bug", child: Text("UI Bug")),
              DropdownMenuItem(
                  value: "Other", child: Text("Other")),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _category = value;
              });
            },
          ),

          const SizedBox(height: 15),

          TextFormField(
            controller: _subjectCtrl,
            decoration: const InputDecoration(
              labelText: "Issue Title",
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value == null || value.isEmpty
                    ? "Please enter issue title"
                    : null,
          ),

          const SizedBox(height: 15),

          TextFormField(
            controller: _descriptionCtrl,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: "Describe the Issue",
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value == null || value.isEmpty
                    ? "Please describe the issue"
                    : null,
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send),
              label: Text(
                  _loading ? "Submitting..." : "Submit Ticket"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003366),
                padding:
                    const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _loading ? null : _submitTicket,
            ),
          ),
        ],
      ),
    ),
  );
}
  @override
  void dispose() {
    _subjectCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Technical Support"),
        backgroundColor: const Color(0xFF003366),
      ),
      body: DefaultTabController(
  length: 2,
  child: Column(
    children: [
      const TabBar(
        labelColor: Color(0xFF003366),
        tabs: [
          Tab(text: "Submit Ticket"),
          Tab(text: "Track Tickets"),
        ],
      ),
      Expanded(
        child: TabBarView(
          children: [
            _buildSupportForm(),
            _buildTrackTickets(),
          ],
        ),
      ),
    ],
  ),
),
    );
  }
}

class _SupportFormTab extends StatelessWidget {
  const _SupportFormTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Put your existing form here"),
    );
  }
}
class _TrackTicketsTab extends StatelessWidget {
  const _TrackTicketsTab();

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return Colors.orange;
      case "in progress":
        return Colors.blue;
      case "resolved":
        return Colors.green;
      case "rejected":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("tech_support_tickets")
          .snapshots(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No tickets found."),
          );
        }

        final tickets = snapshot.data!.docs;

        return ListView.builder(
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            final data =
                tickets[index].data() as Map<String, dynamic>;
            final status = data["status"] ?? "Pending";

            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(data["subject"] ?? ""),
                subtitle: Text("Ticket ID: ${data["ticketId"]}"),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status)
                        .withOpacity(0.15),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
