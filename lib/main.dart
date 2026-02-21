import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const CUJApp());
}
class CUJApp extends StatelessWidget {
  const CUJApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CU Jammu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF003366),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF003366),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),

    
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Central University of Jammu - Student Portal"),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: const AssetImage('assets/images/CU_JAMMU-removebg-preview.png')),
                ),
            ],
          ),
          body: child,
        );
      },
      home: const LoginScreen(),
    );
  }
}