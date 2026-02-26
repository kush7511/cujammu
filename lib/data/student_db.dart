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
  ),

 "24BECCS01": Student(
  roll: "24BECCS01",
  fname:"",
  pnumber: 123,
  name: "Abhay Singh Parihar",
  course: "B.Tech CSE Cybersecurity",
  password: "AbhaySinghParihar123",
  cgpa: 6.1,
  attendance: 80,
  results: [],
  dob:   DateTime(2004, 5, 15),
  attendanceDetails: [],
),

"24BECCS02": Student(
  roll: "24BECCS02",
  fname:"",
  pnumber: 123,
  name: "Abhimanyu Kumar Patel",
  course: "B.Tech CSE Cybersecurity",
  password: "AbhimanyuKumarPatel123",
  cgpa: 6.1,
  attendance: 80,
  results: [],
  attendanceDetails: [],
  dob:   DateTime(2004, 5, 15),
),

"24BECCS03": Student(
  roll: "24BECCS03",
  fname:"",
  pnumber: 123,
  name: "Abufaiz Javed",
  dob:   DateTime(2004, 5, 15),
  course: "B.Tech CSE Cybersecurity",
  password: "AbufaizJaved123",
  cgpa: 6.1,
  attendance: 80,
  results: [],
  attendanceDetails: [],
),

"24BECCS04": Student(
  roll: "24BECCS04",
  fname:"",
  pnumber: 123,
  name: "Aditya Gautam",
  course: "B.Tech CSE Cybersecurity",
  password: "AdityaGautam123",
  cgpa: 6.1,
  dob:   DateTime(2004, 5, 15),
  attendance: 80,
  results: [],
  attendanceDetails: [],
),

"24BECCS05": Student(
  roll: "24BECCS05",
  fname:"",
  pnumber: 123,
  name: "Akhil Alotra",
  course: "B.Tech CSE Cybersecurity",
  password: "AkhilAlotra123",
  cgpa: 6.1,
  attendance: 80,
  results: [],
  dob:   DateTime(2004, 5, 15),
  attendanceDetails: [],
),

"24BECCS06": Student(
  roll: "24BECCS06",
  fname:"",
  pnumber: 123,
  name: "Anand Raj Kashyap",
  course: "B.Tech CSE Cybersecurity",
  password: "AnandRajKashyap123",
  cgpa: 6.1,
  attendance: 80,
  results: [],
  attendanceDetails: [],
  dob:   DateTime(2004, 5, 15),
),

"24BECCS07": Student(
  roll: "24BECCS07",
  name: "Anil Prajapat",
  fname:"",
  pnumber: 123,
  course: "B.Tech CSE Cybersecurity",
  password: "AnilPrajapat123",
  cgpa: 6.1,
  attendance: 80,
  dob:   DateTime(2004, 5, 15),
  results: [],
  attendanceDetails: [],
),

"24BECCS08": Student(
  roll: "24BECCS08",
  fname:"",
  pnumber: 123,
  name: "Anshu Pandey",
  course: "B.Tech CSE Cybersecurity",
  password: "AnshuPandey123",
  cgpa: 6.1,
  attendance: 80,
  results: [],
  attendanceDetails: [],
  dob:   DateTime(2004, 5, 15),
),

"24BECCS09": Student(
  roll: "24BECCS09",
  fname:"",
  pnumber: 123,
  name: "Archana Baghel",
  course: "B.Tech CSE Cybersecurity",
  password: "ArchanaBaghel123",
  cgpa: 6.1,
  attendance: 80,
  results: [],
  attendanceDetails: [],
  dob:   DateTime(2004, 5, 15),
),

"24BECCS10": Student(
  roll: "24BECCS10",
  fname:"",
  pnumber: 123,
  name: "Arun Kumar",
  course: "B.Tech CSE Cybersecurity",
  password: "ArunKumar123",
  cgpa: 6.1,
  attendance: 80,
  results: [],
  dob:   DateTime(2004, 5, 15),
  attendanceDetails: [],
),

"24BECCS11": Student(
  roll: "24BECCS11",
  fname:"",
  pnumber: 123,
  name: "Aryan Singh",
  course: "B.Tech CSE Cybersecurity",
  password: "AryanSingh123",
  cgpa: 6.1,
  attendance: 80,
  dob:   DateTime(2004, 5, 15),
  results: [],
  attendanceDetails: [],
),

"24BECCS12": Student(
  roll: "24BECCS12",
  fname:"",
  pnumber: 123,
  name: "Ayush Jangir",
  course: "B.Tech CSE Cybersecurity",
  password: "AyushJangir123",
  cgpa: 6.1,
  attendance: 80,
  results: [],
  attendanceDetails: [],
  dob:   DateTime(2004, 5, 15),
),

"24BECCS13": Student(
  roll: "24BECCS13",
  name: "Bhanu Jangra",
  fname:"",
  pnumber: 123,
  course: "B.Tech CSE Cybersecurity",
  password: "BhanuJangra123",
  cgpa: 6.1,
  attendance: 80,
  results: [],
  dob:   DateTime(2004, 5, 15),
  attendanceDetails: [],
),

"24BECCS14": Student(
  roll: "24BECCS14",
  name: "Chandan Kumar",
  fname:"",
  pnumber: 123,
  course: "B.Tech CSE Cybersecurity",
  password: "ChandanKumar123",
  cgpa: 6.1,
  dob:   DateTime(2004, 5, 15),
  attendance: 80,
  results: [],
  attendanceDetails: [],
),

"24BECCS15": Student(
  roll: "24BECCS15",
  fname:"",
  pnumber: 123,
  name: "Chegireddy Abhivarsh Reddy",
  course: "B.Tech CSE Cybersecurity",
  password: "ChegireddyAbhivarshReddy123",
  cgpa: 6.1,
  attendance: 80,
  results: [],
  dob:   DateTime(2004, 5, 15),
  attendanceDetails: [],
),

"24BECCS16": Student(
  roll: "24BECCS16",
  fname:"",
  pnumber: 123,
  name: "Cherry Bohra",
  course: "B.Tech CSE Cybersecurity",
  password: "CherryBohra123",
  cgpa: 6.1,
  attendance: 80,
  results: [],
  dob:   DateTime(2004, 5, 15),
  attendanceDetails: [],
),

"24BECCS17": Student(
  roll: "24BECCS17",
  fname:"",
  pnumber: 123,
  name: "Cholleti Rishith Reddy",
  course: "B.Tech CSE Cybersecurity",
  password: "CholletiRishithReddy123",
  cgpa: 6.1,
  attendance: 80,
  results: [],
  attendanceDetails: [],
  dob:   DateTime(2004, 5, 15),
),
"24BECCS18": Student(
  roll: "24BECCS18",
  fname:"",
  pnumber: 123,
  name: "Deepak Kumar",
  course: "B.Tech CSE Cybersecurity",
  password: "DeepakKumar123",
  cgpa: 6.1,
  attendance: 80,
  dob:   DateTime(2004, 5, 15),
  results: [],
  attendanceDetails: [],
),

"24BECCS19": Student(
  roll: "24BECCS19",
  fname:"",
  pnumber: 123,
  name: "Devansh Kushwaha",
  course: "B.Tech CSE Cybersecurity",
  password: "DevanshKushwaha123",
  cgpa: 6.1,
  dob:   DateTime(2004, 5, 15),
  attendance: 80,
  results: [],
  attendanceDetails: [],
),

"24BECCS20": Student(
  roll: "24BECCS20",
  fname:"",
  pnumber: 123,
  name: "Dipesh Kumar",
  course: "B.Tech CSE Cybersecurity",
  password: "DipeshKumar123",
  cgpa: 6.1,
  attendance: 80,
  results: [],
  attendanceDetails: [],
  dob:   DateTime(2004, 5, 15),
),

"24BECCS21": Student(
  roll: "24BECCS21",
  fname:"",
  pnumber: 123,
  name: "Harsh Tyagi",
  course: "B.Tech CSE Cybersecurity",
  password: "HarshTyagi123",
  cgpa: 6.1,
  attendance: 80,
  results: [],
  dob:   DateTime(2004, 5, 15),
  attendanceDetails: [],
),

"24BECCS22": Student(
  roll: "24BECCS22",
  fname:"",
  pnumber: 123,
  name: "Kaustubh Dadheech",
  course: "B.Tech CSE Cybersecurity",
  password: "KaustubhDadheech123",
  cgpa: 6.1,
  attendance: 80,
  dob:   DateTime(2004, 5, 15),
  results: [],
  attendanceDetails: [],
),

"24BECCS23": Student(
  roll: "24BECCS23",
  name: "Khushi Slathia",
  fname:"",
  pnumber: 123,
  course: "B.Tech CSE Cybersecurity",
  password: "KhushiSlathia123",
  cgpa: 6.1,
  attendance: 80,
  results: [],
  dob:   DateTime(2004, 5, 15),
  attendanceDetails: [],
),

"24BECCS24": Student(
  roll: "24BECCS24",
  name: "Kuldeep",
  fname:"",
  pnumber: 123,
  course: "B.Tech CSE Cybersecurity",
  password: "Kuldeep123",
  cgpa: 6.1,
  attendance: 80,
  dob:   DateTime(2004, 5, 15),
  results: [],
  attendanceDetails: [],
),

"24BECCS26": Student(
  roll: "24BECCS26",
  fname:"",
  pnumber: 123,
  name: "Lav Kumar",
  course: "B.Tech CSE Cybersecurity",
  password: "LavKumar123",
  cgpa: 6.1,
  attendance: 80,
  dob:   DateTime(2004, 5, 15),
  results: [],
  attendanceDetails: [],
),

"24BECCS27": Student(
  roll: "24BECCS27",
  fname:"",
  pnumber: 123,
  name: "Md Asim Ansari",
  course: "B.Tech CSE Cybersecurity",
  password: "MdAsimAnsari123",
  cgpa: 6.1,
  attendance: 80,
  results: [],
  dob:   DateTime(2004, 5, 15),
  attendanceDetails: [],
),

"24BECCS28": Student(
  fname:"",
  pnumber: 123,
  roll: "24BECCS28",
  name: "Md Ehtesham Ahmad",
  course: "B.Tech CSE Cybersecurity",
  password: "MdEhteshamAhmad123",
  dob:   DateTime(2004, 5, 15),
  cgpa: 6.1,
  attendance: 80,
  results: [],
  attendanceDetails: [],
),

"24BECCS29": Student(
  roll: "24BECCS29",
  name: "Mohd Sahil Ansari",
  fname:"",
  pnumber: 123,
  course: "B.Tech CSE Cybersecurity",
  password: "MohdSahilAnsari123",
  dob:   DateTime(2004, 5, 15),
  cgpa: 6.1,
  attendance: 80,
  results: [],
  attendanceDetails: [],
),

"24BECCS30": Student(
  roll: "24BECCS30",
  fname:"",
  pnumber: 123,
  name: "Neeraj Singh Shekhawat",
  course: "B.Tech CSE Cybersecurity",
  password: "NeerajSinghShekhawat123",
  cgpa: 6.1,
  attendance: 80,
  results: [],
  dob:   DateTime(2004, 5, 15),
  attendanceDetails: [],
),

"24BECCS31": Student(
  roll: "24BECCS31",
  name: "Neha Gahalot",
  fname:"",
  pnumber: 123,
  course: "B.Tech CSE Cybersecurity",
  password: "NehaGahalot123",
  cgpa: 6.1,
  attendance: 80,
  results: [],
  attendanceDetails: [],
  dob:   DateTime(2004, 5, 15),
),

"24BECCS32": Student(
  roll: "24BECCS32",
  fname:"",
  pnumber: 123,
  name: "Nitish Kumar",
  course: "B.Tech CSE Cybersecurity",
  password: "NitishKumar123",
  cgpa: 6.1,
  attendance: 80,
  dob:   DateTime(2004, 5, 15),
  results: [],
  attendanceDetails: [],
),

"24BECCS33": Student(
  fname:"",
  pnumber: 123,
  roll: "24BECCS33",
  name: "Nitish Kumar Kannaujiya",
  course: "B.Tech CSE Cybersecurity",
  password: "NitishKumarKannaujiya123",
  cgpa: 6.1,
  attendance: 80,
  results: [],
  dob:   DateTime(2004, 5, 15),
  attendanceDetails: [],
),

"24BECCS34": Student(
  roll: "24BECCS34",
  fname:"",
  pnumber: 123,
  name: "Parigya",
  course: "B.Tech CSE Cybersecurity",
  password: "Parigya123",
  cgpa: 6.1,
  attendance: 80,
  results: [],
  dob:   DateTime(2004, 5, 15),
  attendanceDetails: [],
),

"24BECCS35": Student(
  roll: "24BECCS35",
  fname:"",
  pnumber: 123,
  name: "Piyush Kumar Dubey",
  course: "B.Tech CSE Cybersecurity",
  password: "PiyushKumarDubey123",
  cgpa: 6.1,
  dob:   DateTime(2004, 5, 15),
  attendance: 80,
  results: [],
  attendanceDetails: [],
),

"24BECCS36": Student(
  roll: "24BECCS36",
  name: "Piyush Saroj",
  fname:"",
  pnumber: 123,
  course: "B.Tech CSE Cybersecurity",
  password: "PiyushSaroj123",
  cgpa: 6.1,
  dob:   DateTime(2004, 5, 15),
  attendance: 80,
  results: [],
  attendanceDetails: [],
),

"24BECCS37": Student(
  roll: "24BECCS37",
  fname:"",
  pnumber: 123,
  name: "Prashant Raj",
  course: "B.Tech CSE Cybersecurity",
  password: "PrashantRaj123",
  cgpa: 6.1,
  attendance: 80,
  dob:   DateTime(2004, 5, 15),
  results: [],
  attendanceDetails: [],
),

"24BECCS38": Student(
  roll: "24BECCS38",
  fname:"",
  pnumber: 123,
  name: "Prashant Singh",
  course: "B.Tech CSE Cybersecurity",
  password: "PrashantSingh123",
  cgpa: 6.1,
  dob:   DateTime(2004, 5, 15),
  attendance: 80,
  results: [],
  attendanceDetails: [],
),

"24BECCS39": Student(
  roll: "24BECCS39",
  fname:"",
  pnumber: 123,
  name: "Pulkam Abhinav",
  course: "B.Tech CSE Cybersecurity",
  password: "PulkamAbhinav123",
  cgpa: 6.1,
  attendance: 80,
  results: [],
  dob:   DateTime(2004, 5, 15),
  attendanceDetails: [],
),

"24BECCS40": Student(
  roll: "24BECCS40",
  fname:"",
  pnumber: 123,
  name: "Rahul Yadav",
  course: "B.Tech CSE Cybersecurity",
  password: "RahulYadav123",
  cgpa: 6.1,
  attendance: 80,
  results: [],
  dob:   DateTime(2004, 5, 15),
  attendanceDetails: [],
),

"24BECCS41": Student(
  roll: "24BECCS41",
  fname:"",
  pnumber: 123,
  name: "Rajhans Singh",
  course: "B.Tech CSE Cybersecurity",
  password: "RajhansSingh123",
  dob:   DateTime(2004, 5, 15),
  cgpa: 6.1,
  attendance: 80,
  results: [],
  attendanceDetails: [],
),

"24BECCS42": Student(
  roll: "24BECCS42",
  name: "Pranavasi",
  fname:"",
  pnumber: 123,
  course: "B.Tech CSE Cybersecurity",
  password: "Pranavasi123",
  cgpa: 6.1,
  attendance: 80,
  dob:   DateTime(2004, 5, 15),
  results: [],
  attendanceDetails: [],
),

"24BECCS43": Student(
  roll: "24BECCS43",
  fname:"",
  pnumber: 123,
  name: "Samarpita Ghosh",
  course: "B.Tech CSE Cybersecurity",
  password: "SamarpitaGhosh123",
  dob:   DateTime(2004, 5, 15),
  cgpa: 6.1,
  attendance: 80,
  results: [],
  attendanceDetails: [],
),

"24BECCS44": Student(
  fname:"",
  pnumber: 123,
  roll: "24BECCS44",
  name: "Samarth Shrivastava",
  course: "B.Tech CSE Cybersecurity",
  password: "SamarthShrivastava123",
  cgpa: 6.1,
  attendance: 80,
  dob:   DateTime(2004, 5, 15),
  results: [],
  attendanceDetails: [],
),

"24BECCS45": Student(
  roll: "24BECCS45",
  fname:"",
  pnumber: 123,
  name: "Sanjit Singh",
  course: "B.Tech CSE Cybersecurity",
  password: "SanjitSingh123",
  cgpa: 6.1,
  attendance: 80,
  results: [],
  attendanceDetails: [],
  dob:   DateTime(2004, 5, 15),
),

"24BECCS46": Student(
  roll: "24BECCS46",
  fname:"",
  pnumber: 123,
  name: "Satyam Kumar",
  course: "B.Tech CSE Cybersecurity",
  password: "SatyamKumar123",
  cgpa: 6.1,
  attendance: 80,
  results: [],
  dob:   DateTime(2004, 5, 15),
  attendanceDetails: [],
),

"24BECCS47": Student(
  roll: "24BECCS47",
  fname:"",
  pnumber: 123,
  name: "Satyam Kumar Chauhan",
  course: "B.Tech CSE Cybersecurity",
  password: "SatyamKumarChauhan123",
  cgpa: 6.1,
  dob:   DateTime(2004, 5, 15),
  attendance: 80,
  results: [],
  attendanceDetails: [],
),

"24BECCS48": Student(
  fname:"",
  pnumber: 123,
  roll: "24BECCS48",
  name: "Sheikh Adnan Ali",
  course: "B.Tech CSE Cybersecurity",
  password: "SheikhAdnanAli123",
  cgpa: 6.1,
  attendance: 80,
  dob:   DateTime(2004, 5, 15),
  results: [],
  attendanceDetails: [],
),

"24BECCS49": Student(
  roll: "24BECCS49",
  fname:"",
  pnumber: 123,
  name: "Shreya Upadhyay",
  course: "B.Tech CSE Cybersecurity",
  password: "ShreyaUpadhyay123",
  cgpa: 6.1,
  attendance: 80,
  dob:   DateTime(2004, 5, 15),
  results: [],
  attendanceDetails: [],
),

"24BECCS50": Student(
  roll: "24BECCS50",
  name: "Shubham Kumar",
  fname:"",
  pnumber: 123,
  course: "B.Tech CSE Cybersecurity",
  password: "ShubhamKumar123",
  cgpa: 6.1,
  attendance: 80,
  results: [],
  dob:   DateTime(2004, 5, 15),
  attendanceDetails: [],
),

"24BECCS51": Student(
  fname:"",
  pnumber: 123,
  roll: "24BECCS51",
  name: "Sparsh Kumar",
  course: "B.Tech CSE Cybersecurity",
  password: "SparshKumar123",
  cgpa: 6.1,
  attendance: 80,
  dob:   DateTime(2004, 5, 15),
  results: [],
  attendanceDetails: [],
),

"24BECCS52": Student(
  roll: "24BECCS52",
  fname:"",
  pnumber: 123,
  name: "Sudhakar Sharma",
  course: "B.Tech CSE Cybersecurity",
  password: "SudhakarSharma123",
  dob:   DateTime(2004, 5, 15),
  cgpa: 6.1,
  attendance: 80,
  results: [],
  attendanceDetails: [],
),

"24BECCS53": Student(
  roll: "24BECCS53",
  fname:"",
  pnumber: 123,
  name: "Sukhvinder Singh",
  course: "B.Tech CSE Cybersecurity",
  password: "SukhvinderSingh123",
  cgpa: 6.1,
  dob:   DateTime(2004, 5, 15),
  attendance: 80,
  results: [],
  attendanceDetails: [],
),

"24BECCS54": Student(
  roll: "24BECCS54",
  name: "Sukriti Prasad",
  fname:"",
  pnumber: 123,
  course: "B.Tech CSE Cybersecurity",
  password: "SukritiPrasad123",
  cgpa: 6.1,
  attendance: 80,
  dob:   DateTime(2004, 5, 15),
  results: [],
  attendanceDetails: [],
),

"24BECCS55": Student(
  roll: "24BECCS55",
  fname:"",
  pnumber: 123,
  name: "Sumit Sahu",
  course: "B.Tech CSE Cybersecurity",
  password: "SumitSahu123",
  cgpa: 6.1,
  dob:   DateTime(2004, 5, 15),
  attendance: 80,
  results: [],
  attendanceDetails: [],
),

"24BECCS56": Student(
  roll: "24BECCS56",
  fname:"",
  pnumber: 123,
  name: "Tanmay Saini",
  dob:   DateTime(2004, 5, 15),
  course: "B.Tech CSE Cybersecurity",
  password: "TanmaySaini123",
  cgpa: 6.1,
  attendance: 80,
  results: [],
  attendanceDetails: [],
),

"24BECCS57": Student(
  roll: "24BECCS57",
  fname:"",
  dob:   DateTime(2004, 5, 15),
  pnumber: 123,
  name: "Tarundeep Singh",
  course: "B.Tech CSE Cybersecurity",
  password: "TarundeepSingh123",
  cgpa: 6.1,
  attendance: 80,
  results: [],
  attendanceDetails: [],
),

"24BECCS58": Student(
  roll: "24BECCS58",
  fname:"",
  pnumber: 123,
  name: "Urmi Slathia",
  course: "B.Tech CSE Cybersecurity",
  password: "UrmiSlathia123",
  cgpa: 6.1,
  attendance: 80,
  dob:   DateTime(2004, 5, 15),
  results: [],
  attendanceDetails: [],
),

"24BECCS59": Student(
  roll: "24BECCS59",
  fname:"",
  pnumber: 123,
  name: "Vansha Sharma",
  course: "B.Tech CSE Cybersecurity",
  password: "VanshaSharma123",
  cgpa: 6.1,
  dob:   DateTime(2004, 5, 15),
  attendance: 80,
  results: [],
  attendanceDetails: [],
),

"24BECCS60": Student(
  roll: "24BECCS60",
  fname:"",
  pnumber: 123,
  name: "Vikram Aditya Kumar Suman",
  course: "B.Tech CSE Cybersecurity",
  password: "VikramAdityaKumarSuman123",
  cgpa: 6.1,
  attendance: 80,
  dob:   DateTime(2004, 5, 15),
  results: [],
  attendanceDetails: [],
),

"24BECCS61": Student(
  roll: "24BECCS61",
  fname:"",
  pnumber: 123,
  name: "Yashpreet Saxena",
  course: "B.Tech CSE Cybersecurity",
  password: "YashpreetSaxena123",
  cgpa: 6.1,
  attendance: 80,
  results: [],
  dob:   DateTime(2004, 5, 15),
  attendanceDetails: [],
),

"24BECCS62": Student(
  roll: "24BECCS62",
  fname:"",
  pnumber: 123,
  name: "Yogesh Kumar",
  course: "B.Tech CSE Cybersecurity",
  password: "YogeshKumar123",
  cgpa: 6.1,
  attendance: 80,
  results: [],
  attendanceDetails: [], 
  dob:   DateTime(2004, 5, 15),
),
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
  if (roll.trim().toUpperCase() == protectedDeveloperRoll) {
    return "This enrollment number is reserved.";
  }
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
