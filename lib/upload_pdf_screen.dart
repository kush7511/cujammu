import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UploadPDFScreen extends StatefulWidget {
  const UploadPDFScreen({super.key});

  @override
  State<UploadPDFScreen> createState() => _UploadPDFScreenState();
}

class _UploadPDFScreenState extends State<UploadPDFScreen> {

  Future uploadPDF() async {

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {

      var fileBytes = result.files.first.bytes;
      String fileName = result.files.first.name;

      var ref = FirebaseStorage.instance
          .ref()
          .child("documents/$fileName");

      await ref.putData(fileBytes!);

      String downloadUrl = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection("documents")
          .doc(fileName)
          .set({
        "name": fileName,
        "url": downloadUrl,
        "uploadedAt": FieldValue.serverTimestamp()
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("PDF Uploaded Successfully")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload PDF")),
      body: Center(
        child: ElevatedButton(
          onPressed: uploadPDF,
          child: const Text("Upload PDF"),
        ),
      ),
    );
  }
}
