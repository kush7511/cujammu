import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';

class FirebaseStudentService {

  static final _db = FirebaseFirestore.instance;

  static CollectionReference get students =>
      _db.collection("students");

  /// ADD STUDENT
  static Future<void> addStudent(Student student) async {

    await students.doc(student.roll).set({
      "name": student.name,
      "fname": student.fname,
      "pnumber": student.pnumber,
      "dob": student.dob,
      "course": student.course,
      "password": student.password,
      "profileImageBase64": student.profileImageBase64,
      "cgpa": student.cgpa,
      "attendance": student.attendance,
      "results": student.results.map((r) => {
        "code": r.code,
        "name": r.name,
        "credits": r.credits,
        "grade": r.grade,
        "points": r.points,
      }).toList(),
      "attendanceDetails": student.attendanceDetails.map((a) => {
        "subject": a.subject,
        "present": a.present,
        "total": a.total,
      }).toList(),
    });

  }

  /// GET STUDENT
  static Future<Student?> getStudent(String roll) async {

    final doc = await students.doc(roll).get();

    if (!doc.exists) return null;

    return Student.fromFirestore(
      roll: doc.id,
      data: doc.data() as Map<String, dynamic>,
    );

  }

  /// UPDATE CGPA
  static Future<void> updateCGPA(String roll, double cgpa) async {

    await students.doc(roll).update({
      "cgpa": cgpa
    });

  }

  /// UPDATE ATTENDANCE
  static Future<void> updateAttendance(String roll, int attendance) async {

    await students.doc(roll).update({
      "attendance": attendance
    });

  }

  /// UPDATE RESULTS
  static Future<void> updateResults(
      String roll,
      List<Result> results
  ) async {

    await students.doc(roll).update({

      "results": results.map((r) => {
        "code": r.code,
        "name": r.name,
        "credits": r.credits,
        "grade": r.grade,
        "points": r.points,
      }).toList()

    });

  }

  /// RESET PASSWORD
  static Future<void> resetPassword(
      String roll,
      String newPassword
  ) async {

    await students.doc(roll).update({
      "password": newPassword
    });

  }

  /// DELETE STUDENT
  static Future<void> deleteStudent(String roll) async {

    await students.doc(roll).delete();

  }

}