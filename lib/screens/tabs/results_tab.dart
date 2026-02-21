import 'package:flutter/material.dart';
import '../../data/student_db.dart';

class ResultsTab extends StatelessWidget {
  final Student student;
  const ResultsTab({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 15,
        ),
      itemCount: student.results.length,
      itemBuilder: (_, i) {
        final r = student.results[i];
        return Card(
          child: ListTile(
            minTileHeight: 20,
            title: Text(r.name),
            subtitle: Text("Credits: ${r.credits}"),
            trailing: Text(r.grade,
            style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
      },
      ),
    );
  }
}
