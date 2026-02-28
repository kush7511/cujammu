import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

class AdmitCardPage extends StatelessWidget {
  final dynamic student;

  const AdmitCardPage({super.key, required this.student});

  @override
  Widget build(BuildContext context) {

    final uniqueId = "CUJ-${student.roll}-2026-${DateTime.now().millisecondsSinceEpoch}";

    final exams = [
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
        "subject": "Digital Electronics",
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
        "subject": "Operating Systems",
        "date": "17 Feb 2026",
        "time": "10:30 AM - 12:30 PM",
        "venue": "Fabricated Block, Room 1",
      },
      {
        "subject": "Java Programming",
        "date": "17 Feb 2026",
        "time": "2:00 PM - 4:00 PM",
        "venue": "Fabricated Block, Room 1",
      },

    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admit Card"),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _generatePdf(context, exams, uniqueId),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            Image.asset(
              "assets/images/CU_JAMMU-removebg-preview.png",
              height: 80,
            ),

            const SizedBox(height: 10),

            const Text(
              "Central University of Jammu",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const Text(
              "EXAMINATION ADMIT CARD",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Container(
              width: 120,
              height: 140,
              decoration: BoxDecoration(border: Border.all()),
              child: const Center(child: Text("Photo")),
            ),

            const SizedBox(height: 20),

            Text("Admit ID: $uniqueId"),
            Text("Name: ${student.name}"),
            Text("Roll: ${student.roll}"),
            Text("Course: ${student.course}"),
            Text("Father's Name: ${student.fname}"),

            const SizedBox(height: 20),

            const Text(
              "Exam Subjects",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            ...exams.map((exam) => Card(
              child: ListTile(
                title: Text(exam["subject"]!),
                subtitle: Text(
                    "${exam["date"]}\n${exam["time"]}\n${exam["venue"]}"),
              ),
            )),

            const SizedBox(height: 20),

            QrImageView(
              data: uniqueId,
              size: 120,
            ),

            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Candidate Signature"),
                Text("HOD Signature"),
                Text("Exam Incharge"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generatePdf(
      BuildContext context,
      List<Map<String, String>> exams,
      String uniqueId,
      ) async {

    final pdf = pw.Document();

    final logoBytes =
        (await rootBundle.load("assets/images/CU_JAMMU-removebg-preview.png"))
            .buffer
            .asUint8List();

    final logoImage = pw.MemoryImage(logoBytes);

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [

          pw.Center(
            child: pw.Image(logoImage, height: 80),
          ),

          pw.SizedBox(height: 10),

          pw.Center(
            child: pw.Text(
              "Central University of Jammu",
              style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold),
            ),
          ),

          pw.Center(
            child: pw.Text(
              "EXAMINATION ADMIT CARD",
              style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold),
            ),
          ),

          pw.SizedBox(height: 20),

          pw.Container(
            width: 100,
            height: 120,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(),
            ),
            child: pw.Center(child: pw.Text("Photo")),
          ),

          pw.SizedBox(height: 20),

          pw.Text("Admit ID: $uniqueId"),
          pw.Text("Name: ${student.name}"),
          pw.Text("Roll: ${student.roll}"),
          pw.Text("Course: ${student.course}"),
          pw.Text("Father's Name: ${student.fname}"),

          pw.SizedBox(height: 20),

          pw.Text("Exam Subjects:",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),

          pw.SizedBox(height: 10),

          pw.Table.fromTextArray(
            headers: ["Subject", "Date", "Time", "Venue"],
            data: exams.map((exam) {
              return [
                exam["subject"]!,
                exam["date"]!,
                exam["time"]!,
                exam["venue"]!,
              ];
            }).toList(),
          ),

          pw.SizedBox(height: 20),

          pw.Center(
            child: pw.BarcodeWidget(
              barcode: pw.Barcode.qrCode(),
              data: uniqueId,
              width: 100,
              height: 100,
            ),
          ),

          pw.SizedBox(height: 40),

          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                children: [
                  pw.Container(width: 120, child: pw.Divider()),
                  pw.Text("Candidate Signature"),
                ],
              ),
              pw.Column(
                children: [
                  pw.Container(width: 120, child: pw.Divider()),
                  pw.Text("HOD Signature"),
                ],
              ),
              pw.Column(
                children: [
                  pw.Container(width: 120, child: pw.Divider()),
                  pw.Text("Exam Incharge"),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File("${directory.path}/AdmitCard_${student.roll}.pdf");

    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Admit Card downloaded successfully")),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }
}