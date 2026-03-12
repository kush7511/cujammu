import 'package:flutter/material.dart';


//Creatig thr privscy policy class aligwith the 
class PrivacyPolicy extends StatefulWidget{
  const PrivacyPolicy({super.key});

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
      ),
      body: ListView(
        padding:  const EdgeInsets.all(10),
        children: const [
          ExpansionTile(
            title: Text("1. Information we collect"),
            children: [
              Padding(padding: EdgeInsets.all(8.0), 
              child: Text("""
      We may collect the following types of information:
      1. Personal Information
      When you use the application, we may collect:
      • Name
      • University email ID
      • Student ID or registration number
      • Phone number (if provided)
      This information helps us identify users and provide services within the university transportation system.\n
      2. Location Information
      The app may collect real-time location data when you request EV pickup.
      This information is used to:
      • Show your pickup location to the EV driver
      • Enable navigation for the driver
      • Improve transportation services inside the university campus
      Location data is only used when necessary for ride requests.\n
      3. Device Information
      We may automatically collect limited device information such as:
      • Device type
      • Operating system
      • App version
      • Crash logs\n
      This helps us improve the app performance."""),
              )
            ],
          ),
ExpansionTile(title: 
Text("2. How we use your information"), 
children: [
Padding(padding: EdgeInsets.only(top: 2), 
child: Text("""
We use the collected information to:
• Provide EV pickup request services
• Show the student's location to EV drivers
• Manage ride requests
• Improve app performance
• Fix bugs and technical issues
• Maintain security of the platform\n
We do not sell or rent your personal information to third parties."""),)
          ],)
        ],
      ),
    );
  }
}