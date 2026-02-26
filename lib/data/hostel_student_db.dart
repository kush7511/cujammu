import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

enum HostelBlock {
  spmBoys,
  brsBoys,
  shailputriGirls,
}

extension HostelBlockX on HostelBlock {
  String get displayName {
    switch (this) {
      case HostelBlock.spmBoys:
        return "SPM Boys Hostel";
      case HostelBlock.brsBoys:
        return "BRS Boys Hostel";
      case HostelBlock.shailputriGirls:
        return "Shailputri Girls Hostel";
    }
  }

  String get storageKey {
    switch (this) {
      case HostelBlock.spmBoys:
        return "hostel_students_spm_boys_v1";
      case HostelBlock.brsBoys:
        return "hostel_students_brs_boys_v1";
      case HostelBlock.shailputriGirls:
        return "hostel_students_shailputri_girls_v1";
    }
  }
}

class HostelStudent {
  final String enrollmentNumber;
  final String password;
  final String name;
  final String roomNumber;
  final String fatherName;
  final String phoneNumber;
  final String email;
  final String department;
  final String academicYear;
  final String guardianContact;
  final String? profileImageBase64;
  final List<HostelLeaveApplication> leaveApplications;
  final List<HostelComplaint> complaints;

  // Backward-compat helper for older references using singular field name.
  List<HostelLeaveApplication> get leaveApplication => leaveApplications;

  const HostelStudent({
    required this.enrollmentNumber,
    required this.password,
    required this.name,
    required this.roomNumber,
    required this.fatherName,
    required this.phoneNumber,
    required this.email,
    required this.department,
    required this.academicYear,
    required this.guardianContact,
    this.profileImageBase64,
    required this.leaveApplications,
    required this.complaints,
  });

  HostelStudent copyWith({
    String? enrollmentNumber,
    String? password,
    String? name,
    String? roomNumber,
    String? fatherName,
    String? phoneNumber,
    String? email,
    String? department,
    String? academicYear,
    String? guardianContact,
    String? profileImageBase64,
    bool clearProfileImage = false,
    List<HostelLeaveApplication>? leaveApplications,
    List<HostelComplaint>? complaints,
  }) {
    return HostelStudent(
      enrollmentNumber: enrollmentNumber ?? this.enrollmentNumber,
      password: password ?? this.password,
      name: name ?? this.name,
      roomNumber: roomNumber ?? this.roomNumber,
      fatherName: fatherName ?? this.fatherName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      department: department ?? this.department,
      academicYear: academicYear ?? this.academicYear,
      guardianContact: guardianContact ?? this.guardianContact,
      profileImageBase64: clearProfileImage
          ? null
          : (profileImageBase64 ?? this.profileImageBase64),
      leaveApplications: leaveApplications ?? this.leaveApplications,
      complaints: complaints ?? this.complaints,
    );
  }

  Map<String, dynamic> toJson() => {
    "enrollmentNumber": enrollmentNumber,
    "password": password,
    "name": name,
    "roomNumber": roomNumber,
    "fatherName": fatherName,
    "phoneNumber": phoneNumber,
    "email": email,
    "department": department,
    "academicYear": academicYear,
    "guardianContact": guardianContact,
    "profileImageBase64": profileImageBase64,
    "leaveApplications": leaveApplications.map((e) => e.toJson()).toList(),
    "complaints": complaints.map((e) => e.toJson()).toList(),
  };

  factory HostelStudent.fromJson(Map<String, dynamic> json) {
    final enrollmentNumber = json["enrollmentNumber"] as String? ?? "UNKNOWN";
    final parsedLeaves = json["leaveApplications"];
    final parsedComplaints = json["complaints"];
    return HostelStudent(
      enrollmentNumber: enrollmentNumber,
      password: json["password"] as String? ?? "",
      name: json["name"] as String? ?? "Hostel Student",
      roomNumber: json["roomNumber"] as String? ?? "Not Assigned",
      fatherName: json["fatherName"] as String? ?? "Not Available",
      phoneNumber: json["phoneNumber"] as String? ?? "Not Available",
      email:
          json["email"] as String? ??
          "${enrollmentNumber.toLowerCase()}@student.cujammu.ac.in",
      department:
          json["department"] as String? ?? "B.Tech CSE Cybersecurity",
      academicYear: json["academicYear"] as String? ?? "1st Year",
      guardianContact: json["guardianContact"] as String? ?? "Not Available",
      profileImageBase64: json["profileImageBase64"] as String?,
      leaveApplications: parsedLeaves is List
          ? parsedLeaves
                .whereType<Map>()
                .map(
                  (e) => HostelLeaveApplication.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : [],
      complaints: parsedComplaints is List
          ? parsedComplaints
                .whereType<Map>()
                .map(
                  (e) => HostelComplaint.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : [],
    );
  }
}

// Backward-compat alias for older typo/casing references.
typedef HostelleaveApplication = HostelLeaveApplication;

class HostelComplaint {
  final String id;
  final String category;
  final String details;
  final DateTime reportedOn;
  final String status;

  const HostelComplaint({
    required this.id,
    required this.category,
    required this.details,
    required this.reportedOn,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "category": category,
    "details": details,
    "reportedOn": reportedOn.toIso8601String(),
    "status": status,
  };

  factory HostelComplaint.fromJson(Map<String, dynamic> json) {
    return HostelComplaint(
      id: json["id"] as String,
      category: json["category"] as String,
      details: json["details"] as String,
      reportedOn: DateTime.parse(json["reportedOn"] as String),
      status: json["status"] as String,
    );
  }
}

class HostelLeaveApplication {
  final String id;
  final String leaveType;
  final DateTime fromDate;
  final DateTime toDate;
  final String reason;
  final String destination;
  final String guardianContact;
  final String emergencyContact;
  final DateTime appliedOn;
  final String status;

  const HostelLeaveApplication({
    required this.id,
    required this.leaveType,
    required this.fromDate,
    required this.toDate,
    required this.reason,
    required this.destination,
    required this.guardianContact,
    required this.emergencyContact,
    required this.appliedOn,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "leaveType": leaveType,
    "fromDate": fromDate.toIso8601String(),
    "toDate": toDate.toIso8601String(),
    "reason": reason,
    "destination": destination,
    "guardianContact": guardianContact,
    "emergencyContact": emergencyContact,
    "appliedOn": appliedOn.toIso8601String(),
    "status": status,
  };

  factory HostelLeaveApplication.fromJson(Map<String, dynamic> json) {
    return HostelLeaveApplication(
      id: json["id"] as String,
      leaveType: json["leaveType"] as String,
      fromDate: DateTime.parse(json["fromDate"] as String),
      toDate: DateTime.parse(json["toDate"] as String),
      reason: json["reason"] as String,
      destination: json["destination"] as String,
      guardianContact: json["guardianContact"] as String,
      emergencyContact: json["emergencyContact"] as String,
      appliedOn: DateTime.parse(json["appliedOn"] as String),
      status: json["status"] as String,
    );
  }
}

const HostelStudent _developmentStudentSeed = HostelStudent(
  enrollmentNumber: "24BECCS25",
  password: "Kush@7511",
  name: "Kush Kumar",
  roomNumber: "Dev-Room-01",
  fatherName: "Naresh Chand",
  phoneNumber: "9541232575",
  email: "24beccs25@student.cujammu.ac.in",
  department: "B.Tech CSE Cybersecurity",
  academicYear: "2nd Year",
  guardianContact: "9541232575",
  leaveApplications: [],
  complaints: [],
);

Map<String, HostelStudent> _defaultBlockData() => {
  _developmentStudentSeed.enrollmentNumber: _developmentStudentSeed,
};

final Map<HostelBlock, Map<String, HostelStudent>> _hostelDatabases = {
  HostelBlock.spmBoys: _defaultBlockData(),
  HostelBlock.brsBoys: _defaultBlockData(),
  HostelBlock.shailputriGirls: _defaultBlockData(),
};

bool _loadedHostelDatabases = false;

Map<String, HostelStudent> hostelStudentsForBlock(HostelBlock block) =>
    _hostelDatabases[block]!;

Future<void> loadHostelDatabases() async {
  if (_loadedHostelDatabases) return;

  final prefs = await SharedPreferences.getInstance();
  for (final block in HostelBlock.values) {
    final raw = prefs.getString(block.storageKey);
    if (raw == null || raw.trim().isEmpty) {
      continue;
    }
    try {
      final parsed = jsonDecode(raw);
      if (parsed is! List) continue;
      final map = <String, HostelStudent>{};
      for (final entry in parsed) {
        if (entry is! Map) continue;
        final student = HostelStudent.fromJson(Map<String, dynamic>.from(entry));
        map[student.enrollmentNumber] = student;
      }
      _hostelDatabases[block] = map;
    } catch (_) {
      // Ignore malformed cache for this block.
    }
  }

  // Development seed is kept in every block so login works everywhere in dev.
  for (final block in HostelBlock.values) {
    _hostelDatabases[block]!.putIfAbsent(
      _developmentStudentSeed.enrollmentNumber,
      () => _developmentStudentSeed,
    );
  }

  _loadedHostelDatabases = true;
}

Future<void> _saveBlockDatabase(HostelBlock block) async {
  final prefs = await SharedPreferences.getInstance();
  final payload = _hostelDatabases[block]!.values.map((e) => e.toJson()).toList();
  await prefs.setString(block.storageKey, jsonEncode(payload));
}

HostelStudent? authenticateHostelStudent({
  required HostelBlock block,
  required String enrollmentNumber,
  required String password,
}) {
  final cleanEnrollment = enrollmentNumber.trim();
  final student = _hostelDatabases[block]![cleanEnrollment];
  if (student == null) return null;
  if (student.password != password.trim()) return null;
  return student;
}

Future<String?> registerHostelStudent({
  required HostelBlock block,
  required String enrollmentNumber,
  required String password,
  required String name,
  required String roomNumber,
}) async {
  await loadHostelDatabases();
  final cleanEnrollment = enrollmentNumber.trim();
  if (cleanEnrollment.isEmpty) {
    return "Enrollment number is required.";
  }
  for (final currentBlock in HostelBlock.values) {
    if (currentBlock == block) continue;
    if (_hostelDatabases[currentBlock]!.containsKey(cleanEnrollment)) {
      return "This enrollment number already exists in ${currentBlock.displayName}.";
    }
  }
  if (_hostelDatabases[block]!.containsKey(cleanEnrollment)) {
    return "Enrollment number already exists in ${block.displayName}.";
  }
  _hostelDatabases[block]![cleanEnrollment] = HostelStudent(
    enrollmentNumber: cleanEnrollment,
    password: password.trim(),
    name: name.trim().isEmpty ? "Hostel Student" : name.trim(),
    roomNumber: roomNumber.trim().isEmpty ? "Not Assigned" : roomNumber.trim(),
    fatherName: "Not Available",
    phoneNumber: "Not Available",
    email: "${cleanEnrollment.toLowerCase()}@student.cujammu.ac.in",
    department: "Not Available",
    academicYear: "Not Available",
    guardianContact: "Not Available",
    leaveApplications: const [],
    complaints: const [],
  );
  await _saveBlockDatabase(block);
  return null;
}

Future<HostelStudent?> updateHostelStudentProfileImage({
  required HostelBlock block,
  required String enrollmentNumber,
  required String? profileImageBase64,
}) async {
  await loadHostelDatabases();
  final cleanEnrollment = enrollmentNumber.trim();
  final existing = _hostelDatabases[block]![cleanEnrollment];
  if (existing == null) return null;

  final updated = (profileImageBase64 == null || profileImageBase64.trim().isEmpty)
      ? existing.copyWith(clearProfileImage: true)
      : existing.copyWith(profileImageBase64: profileImageBase64);
  _hostelDatabases[block]![cleanEnrollment] = updated;
  await _saveBlockDatabase(block);
  return updated;
}

Future<HostelStudent?> submitHostelLeaveApplication({
  required HostelBlock block,
  required String enrollmentNumber,
  required HostelLeaveApplication application,
}) async {
  await loadHostelDatabases();
  final cleanEnrollment = enrollmentNumber.trim();
  final existing = _hostelDatabases[block]![cleanEnrollment];
  if (existing == null) return null;
  final updatedLeaves = <HostelLeaveApplication>[
    application,
    ...existing.leaveApplications,
  ];
  final updated = existing.copyWith(leaveApplications: updatedLeaves);
  _hostelDatabases[block]![cleanEnrollment] = updated;
  await _saveBlockDatabase(block);
  return updated;
}

Future<HostelStudent?> submitHostelComplaint({
  required HostelBlock block,
  required String enrollmentNumber,
  required HostelComplaint complaint,
}) async {
  await loadHostelDatabases();
  final cleanEnrollment = enrollmentNumber.trim();
  final existing = _hostelDatabases[block]![cleanEnrollment];
  if (existing == null) return null;
  final updatedComplaints = <HostelComplaint>[
    complaint,
    ...existing.complaints,
  ];
  final updated = existing.copyWith(complaints: updatedComplaints);
  _hostelDatabases[block]![cleanEnrollment] = updated;
  await _saveBlockDatabase(block);
  return updated;
}

Future<String?> deleteHostelStudent({
  required HostelBlock block,
  required String enrollmentNumber,
  required String password,
}) async {
  await loadHostelDatabases();
  final cleanEnrollment = enrollmentNumber.trim();
  final existing = _hostelDatabases[block]![cleanEnrollment];
  if (existing == null) {
    return "Account not found in ${block.displayName}.";
  }
  if (existing.password != password.trim()) {
    return "Incorrect password.";
  }
  _hostelDatabases[block]!.remove(cleanEnrollment);
  await _saveBlockDatabase(block);
  return null;
}
