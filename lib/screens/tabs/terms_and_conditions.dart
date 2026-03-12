import 'package:flutter/material.dart';

class TermsandConditions extends StatefulWidget {
  const TermsandConditions({super.key});

  @override
  State<TermsandConditions> createState() => _TermsandConditionsState();
}

class _TermsandConditionsState extends State<TermsandConditions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms & Conditions"),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text(
          '''
These Terms and Conditions govern the use of the Student CUJ App, a mobile application developed to assist students of Central University of Jammu with campus electric vehicle (EV) transportation services.
By downloading, installing, or using the Student CUJ App, you agree to comply with and be bound by these Terms and Conditions.

1. Acceptance of Terms
By accessing or using this application, you confirm that you are a student, staff member, or authorized user affiliated with Central University of Jammu and agree to these terms.

2. Purpose of the Application
The Student CUJ App is intended to:
- Facilitate booking and tracking of campus EV transportation.
- Provide information related to routes, schedules, and availability.
- Improve convenience and accessibility within the university campus.

3. User Responsibilities
You agree to:
- Provide accurate and current information during registration or use.
- Use the app only for lawful and intended purposes.
- Not misuse the app by making false bookings, submitting misleading information, or disrupting service operations.

4. Booking and Usage Rules
- EV rides are subject to availability.
- Priority may be given based on university policies, emergencies, or special requirements.
- Repeated no-shows or misuse of booking privileges may lead to suspension of access.

5. Data Collection and Privacy
The app may collect user information such as:
- Name
- Enrollment or university ID
- Contact details
- Location for ride tracking purposes

This information is used only for service delivery, app improvement, and university administration, and will be handled according to the university's privacy and data protection practices.

6. Service Availability
While we strive to keep the app operational and accurate, we do not guarantee uninterrupted availability. Services may be suspended temporarily for maintenance, technical issues, or operational reasons.

7. Limitation of Liability
The university and app developers shall not be held liable for:
- Delays or interruptions in EV services
- Inaccurate location or route information
- Losses resulting from misuse or unauthorized access to the application

8. Intellectual Property
All content, branding, features, and functionality within the app are the property of Central University of Jammu or its authorized developers and may not be copied, modified, or redistributed without permission.

9. Termination of Access
The university reserves the right to suspend or terminate access to the app for users who violate these Terms and Conditions or misuse university transportation resources.

10. Modifications to Terms
We reserve the right to update or modify these Terms and Conditions at any time. Continued use of the app after changes are made constitutes acceptance of the revised terms.

11. Governing Law
These Terms and Conditions shall be governed by the laws of India, and any disputes will fall under the jurisdiction of courts located in Jammu & Kashmir, India.

12. Contact
For questions regarding these Terms and Conditions, please contact:
Central University of Jammu
Bagla, Rahya-Suchani (Bagla), District Samba
Jammu and Kashmir, India
''',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
      ),
    );
  }
}
