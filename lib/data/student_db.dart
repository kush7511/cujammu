import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Student {
  final String roll;
  final String name;
  final String fname;
  final int pnumber;
  final DateTime dob;
  final String course;
  final String password;
  final String? profileImageBase64;
  final double cgpa;
  final int attendance;
  final List<Result> results;
  final List<Attendance> attendanceDetails;

  Student({
    required this.roll,
    required this.fname,
    required this.dob,
    required this.pnumber,
    required this.name,
    required this.course,
    required this.password,
    this.profileImageBase64,
    required this.cgpa,
    required this.attendance,
    required this.results,
    required this.attendanceDetails,
  });

  Student copyWith({
    String? roll,
    String? name,
    String? fname,
    int? pnumber,
    DateTime? dob,
    String? course,
    String? password,
    String? profileImageBase64,
    bool clearProfileImage = false,
    double? cgpa,
    int? attendance,
    List<Result>? results,
    List<Attendance>? attendanceDetails,
  }) {
    return Student(
      roll: roll ?? this.roll,
      fname: fname ?? this.fname,
      dob: dob ?? this.dob,
      pnumber: pnumber ?? this.pnumber,
      name: name ?? this.name,
      course: course ?? this.course,
      password: password ?? this.password,
      profileImageBase64: clearProfileImage
          ? null
          : (profileImageBase64 ?? this.profileImageBase64),
      cgpa: cgpa ?? this.cgpa,
      attendance: attendance ?? this.attendance,
      results: results ?? this.results,
      attendanceDetails: attendanceDetails ?? this.attendanceDetails,
    );
  }

  Map<String, dynamic> toJson() => {
    "roll": roll,
    "name": name,
    "fname": fname,
    "pnumber": pnumber,
    "dob": dob.toIso8601String(),
    "course": course,
    "password": password,
    "profileImageBase64": profileImageBase64,
    "cgpa": cgpa,
    "attendance": attendance,
    "results": results.map((r) => r.toJson()).toList(),
    "attendanceDetails": attendanceDetails.map((a) => a.toJson()).toList(),
  };

  factory Student.fromJson(Map<String, dynamic> json) {
    final parsedResults = json["results"];
    final parsedAttendance = json["attendanceDetails"];
    return Student(
      roll: json["roll"] as String,
      fname: json["fname"] as String,
      dob: DateTime.parse(json["dob"] as String),
      pnumber: (json["pnumber"] as num).toInt(),
      name: json["name"] as String,
      course: json["course"] as String,
      password: json["password"] as String,
      profileImageBase64: json["profileImageBase64"] as String?,
      cgpa: (json["cgpa"] as num).toDouble(),
      attendance: json["attendance"] as int,
      results: parsedResults is List
          ? parsedResults
                .whereType<Map>()
                .map((e) => Result.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : [],
      attendanceDetails: parsedAttendance is List
          ? parsedAttendance
                .whereType<Map>()
                .map((e) => Attendance.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : [],
    );
  }
}

class Result {
  final String code;
  final String name;
  final int credits;
  final String grade;
  final int points;

  Result(this.code, this.name, this.credits, this.grade, this.points);

  Map<String, dynamic> toJson() => {
    "code": code,
    "name": name,
    "credits": credits,
    "grade": grade,
    "points": points,
  };

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    json["code"] as String,
    json["name"] as String,
    json["credits"] as int,
    json["grade"] as String,
    json["points"] as int,
  );
}

class Attendance {
  final String subject;
  final int present;
  final int total;

  Attendance(this.subject, this.present, this.total);

  Map<String, dynamic> toJson() => {
    "subject": subject,
    "present": present,
    "total": total,
  };

  factory Attendance.fromJson(Map<String, dynamic> json) => Attendance(
    json["subject"] as String,
    json["present"] as int,
    json["total"] as int,
  );
}

final Map<String, Student> studentDB = {
  "24BECCS25": Student(
    roll: "24BECCS25",
    fname: "Naresh chand",
    pnumber: 9541232575,
    dob: DateTime(2004, 5, 15),
    name: "Kush Kumar",
    course: "B.Tech CSE Cybersecurity",
    password: "Kush@7511",
    cgpa: 6.1,
    attendance: 80,
    results: [
      Result("CCS101", "Intro to Programming", 4, "A", 10),
      Result("CCS102", "Digital Logic", 3, "B+", 9),
      Result("CCSMA101", "Mathematics I", 4, "A", 10),
    ],
    attendanceDetails: [
      Attendance("Software Engineering", 42, 45),
      Attendance("Java Programming", 30, 40),
      Attendance("Machine Learning", 35, 40),
      Attendance("DBMS", 25, 30),
      Attendance("Java programming Lab", 22, 25),
      Attendance("Machine Learning Lab", 5, 10),
      Attendance("DBMS - Lab", 5, 10),
      Attendance("Operating system",3, 5),
      Attendance("Operating system - Lab", 2, 3),
    ],
  )
};

const String protectedDeveloperRoll = "24BECCS25";
const String _registeredStudentsKey = "registered_students_v1";
bool _loadedRegisteredStudents = false;
const Set<String> _protectedStudentRolls = {protectedDeveloperRoll};

bool isProtectedStudentRoll(String roll) => _protectedStudentRolls.contains(roll);

Future<void> loadRegisteredStudents() async {
  if (_loadedRegisteredStudents) return;

  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_registeredStudentsKey);
  if (raw == null || raw.trim().isEmpty) {
    _loadedRegisteredStudents = true;
    return;
  }

  try {
    final parsed = jsonDecode(raw);
    if (parsed is List) {
      for (final item in parsed) {
        if (item is Map) {
          final student = Student.fromJson(Map<String, dynamic>.from(item));
          studentDB[student.roll] = student;
        }
      }
    }
  } catch (_) {
    // Ignore invalid cache and continue with bundled records.
  }

  _loadedRegisteredStudents = true;
}

Future<void> saveRegisteredStudents() async {
  final prefs = await SharedPreferences.getInstance();
  final students = studentDB.values.map((s) => s.toJson()).toList();
  await prefs.setString(_registeredStudentsKey, jsonEncode(students));
}

Future<String?> registerStudent({
  required String roll,
  required String name,
  required String fname,
  required int pnumber,
  required DateTime dob,
  required String course,
  required String password,
}) async {
  await loadRegisteredStudents();
  if (studentDB.containsKey(roll)) {
    return "Enrollment number already exists.";
  }

  studentDB[roll] = Student(
    roll: roll,
    fname: fname,
    dob: dob,
    pnumber: pnumber,
    name: name,
    course: course,
    password: password,
    profileImageBase64: null,
    cgpa: 0,
    attendance: 0,
    results: const [],
    attendanceDetails: const [],
  );
  await saveRegisteredStudents();
  return null;
}

Future<void> updateStudentProfileImage({
  required String roll,
  required String? profileImageBase64,
}) async {
  await loadRegisteredStudents();
  final existing = studentDB[roll];
  if (existing == null) return;
  if (profileImageBase64 == null || profileImageBase64.trim().isEmpty) {
    studentDB[roll] = existing.copyWith(clearProfileImage: true);
  } else {
    studentDB[roll] = existing.copyWith(profileImageBase64: profileImageBase64);
  }
  await saveRegisteredStudents();
}

Future<String?> deleteStudentAccount({
  required String roll,
  required String password,
}) async {
  await loadRegisteredStudents();

  final existing = studentDB[roll];
  if (existing == null) {
    return "Account not found for this enrollment number.";
  }
  if (existing.password != password) {
    return "Incorrect password.";
  }

  studentDB.remove(roll);
  await saveRegisteredStudents();
  return null;
}
