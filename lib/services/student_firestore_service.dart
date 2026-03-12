import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/student.dart';

class StudentFirestoreService {
  static const String protectedDeveloperRoll = "24BECCS25";
  static const Set<String> _protectedStudentRolls = {protectedDeveloperRoll};

  static bool isProtectedStudentRoll(String roll) {
    return _protectedStudentRolls.contains(_normalizeRoll(roll));
  }

  static String _normalizeRoll(String roll) => roll.trim().toUpperCase();

  static CollectionReference<Map<String, dynamic>> get _studentsRef =>
      FirebaseFirestore.instance.collection("students");

  static Future<Student?> fetchStudentByRoll(String roll) async {
    final cleanRoll = _normalizeRoll(roll);
    if (cleanRoll.isEmpty) return null;

    final doc = await _fetchStudentDoc(cleanRoll);
    if (doc == null) return null;
    final data = doc.data();
    if (data == null) return null;
    return Student.fromFirestore(roll: cleanRoll, data: data);
  }

  static Future<Student?> authenticate({
    required String roll,
    required String password,
  }) async {
    final cleanRoll = _normalizeRoll(roll);
    final cleanPassword = password.trim();
    if (cleanRoll.isEmpty || cleanPassword.isEmpty) return null;

    final doc = await _fetchStudentDoc(cleanRoll);
    if (doc == null) return null;
    final data = doc.data();
    if (data == null) return null;

    final storedPassword = (data["password"] ?? "").toString();
    if (storedPassword != cleanPassword) return null;

    return Student.fromFirestore(roll: cleanRoll, data: data);
  }

  static Future<Student?> updateProfileImage({
    required String roll,
    required String? profileImageBase64,
  }) async {
    final cleanRoll = _normalizeRoll(roll);
    if (cleanRoll.isEmpty) return null;

    final doc = await _fetchStudentDoc(cleanRoll);
    if (doc == null) return null;
    final data = doc.data();
    if (data == null) return null;

    final imageValue =
        profileImageBase64 == null || profileImageBase64.trim().isEmpty
        ? null
        : profileImageBase64;
    await doc.reference.update({"profileImageBase64": imageValue});

    final updated = await doc.reference.get();
    final updatedData = updated.data();
    if (updatedData == null) return null;
    return Student.fromFirestore(roll: cleanRoll, data: updatedData);
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>?> _fetchStudentDoc(
    String cleanRoll,
  ) async {
    final byId = await _studentsRef.doc(cleanRoll).get();
    if (byId.exists) return byId;

    final query = await _studentsRef.where("roll", isEqualTo: cleanRoll).limit(1).get();
    if (query.docs.isEmpty) return null;
    return query.docs.first;
  }
}
