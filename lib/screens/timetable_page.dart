import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class TimetablePage extends StatelessWidget {
  const TimetablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Class Timetable"),
      ),
      body: SfPdfViewer.asset(
        'assets/pdfs/timetable.pdf',
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: TimetablePage(),
  ));
}