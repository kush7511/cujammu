import 'package:flutter/material.dart';
import '../data/student_db.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final rollCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  String error = "";

  void login() {
    final roll = rollCtrl.text.trim();
    final pass = passCtrl.text.trim();

    if (studentDB.containsKey(roll) &&
        studentDB[roll]!.password == pass) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(student: studentDB[roll]!),
        ),
      );
    } else {
      setState(() => error = "Invalid Enrollment Number or Password");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF003366), Color(0xFF001F3F)],
          ),
        ),
        child: Center(
          child: Card(
            elevation: 10,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: 320,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Central University of Jammu",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF003366),
                      ),
                    ),
                    Padding(padding: const EdgeInsets.only(top: 60)),
                    Image.asset('assets/images/CU_JAMMU-removebg-preview.png',
                    fit: BoxFit.cover,
                    width: 150,
                    height: 130,
                    ),
                    const SizedBox(height: 100),
                    TextField(
                      controller: rollCtrl,
                      decoration: const InputDecoration(
                        labelText: "Enrollment Number",
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: passCtrl,
                      obscureText: true,
                      decoration:
                          const InputDecoration(labelText: "Password"),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: login,
                      child: const Text("Login"),
                    ),
                    Padding(padding: const EdgeInsets.only(top: 20)),
                    Text("if your name is Kush Kumar then your password will be KushKumar123", 
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold,color: const Color.fromARGB(255, 4, 83, 7)),
                    ),
                    if (error.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(error,
                            style: const TextStyle(color: Colors.red)),
                      )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
