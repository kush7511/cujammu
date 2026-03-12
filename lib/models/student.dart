import 'package:cloud_firestore/cloud_firestore.dart';

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

  const Student({
    required this.roll,
    required this.name,
    required this.fname,
    required this.pnumber,
    required this.dob,
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
      name: name ?? this.name,
      fname: fname ?? this.fname,
      pnumber: pnumber ?? this.pnumber,
      dob: dob ?? this.dob,
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

  factory Student.fromFirestore({
    required String roll,
    required Map<String, dynamic> data,
  }) {
    DateTime parseDob(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) {
        final parsed = DateTime.tryParse(value);
        if (parsed != null) return parsed;
      }
      return DateTime(2000, 1, 1);
    }

    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? "") ?? 0;
    }

    double parseDouble(dynamic value) {
      if (value is double) return value;
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? "") ?? 0;
    }

    List<Result> parseResults(dynamic raw) {
      if (raw is! List) return const [];
      return raw.whereType<Map>().map((item) {
        final map = Map<String, dynamic>.from(item);
        return Result(
          (map["code"] ?? "").toString(),
          (map["name"] ?? "").toString(),
          parseInt(map["credits"]),
          (map["grade"] ?? "").toString(),
          parseInt(map["points"]),
        );
      }).toList();
    }

    List<Attendance> parseAttendance(dynamic raw) {
      if (raw is! List) return const [];
      return raw.whereType<Map>().map((item) {
        final map = Map<String, dynamic>.from(item);
        return Attendance(
          (map["subject"] ?? "").toString(),
          parseInt(map["present"]),
          parseInt(map["total"]),
        );
      }).toList();
    }

    return Student(
      roll: roll,
      name: (data["name"] ?? "").toString(),
      fname: (data["fname"] ?? "").toString(),
      pnumber: parseInt(data["pnumber"]),
      dob: parseDob(data["dob"]),
      course: (data["course"] ?? "").toString(),
      password: (data["password"] ?? "").toString(),
      profileImageBase64: data["profileImageBase64"]?.toString(),
      cgpa: parseDouble(data["cgpa"]),
      attendance: parseInt(data["attendance"]),
      results: parseResults(data["results"]),
      attendanceDetails: parseAttendance(data["attendanceDetails"]),
    );
  }
}

class Result {
  final String code;
  final String name;
  final int credits;
  final String grade;
  final int points;

  const Result(this.code, this.name, this.credits, this.grade, this.points);
}

class Attendance {
  final String subject;
  final int present;
  final int total;

  const Attendance(this.subject, this.present, this.total);
}
