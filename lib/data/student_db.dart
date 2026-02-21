class Student {
  final String roll;
  final String name;
  final String fname;
  final int pnumber;
  final DateTime dob;
  final String course;
  final String password;
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
    required this.cgpa,
    required this.attendance,
    required this.results,
    required this.attendanceDetails,
  });
}

class Result {
  final String code;
  final String name;
  final int credits;
  final String grade;
  final int points;

  Result(this.code, this.name, this.credits, this.grade, this.points);
}

class Attendance {
  final String subject;
  final int present;
  final int total;

  Attendance(this.subject, this.present, this.total);
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