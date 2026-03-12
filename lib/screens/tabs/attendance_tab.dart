import 'package:flutter/material.dart';
import '../../models/student.dart';

class AttendanceTab extends StatelessWidget {
  final Student student;
  const AttendanceTab({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: student.attendanceDetails.map((a) {
        final percent = a.present / a.total;
        return Card(
          child: ListTile(
            title: Text(a.subject),
            subtitle: LinearProgressIndicator(value: percent),
            trailing: Text("${(percent * 100).round()}%"),
          ),
        );
      }).toList(),
    );
  }
}
