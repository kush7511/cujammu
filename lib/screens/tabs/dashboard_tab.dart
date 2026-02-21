import 'package:cuj/screens/transport_page.dart';
import 'package:flutter/material.dart';
import '../../data/student_db.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cuj/screens/timetable_page.dart';

class DashboardTab extends StatelessWidget {
  final Student student;
  const DashboardTab({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        children: const [
          TimeTable(
            title: "Timetable",
            icon: Icons.calendar_today,
            color: Colors.blue,
          ),

          DashboardCard(
            title: "Assignments",
            icon: Icons.assignment,
            color: Colors.orange,
          ),



          DashboardCard(
            title: "Fee Payment",
            icon: Icons.account_balance_wallet,
            color: Colors.purple,
          ),

          DashboardCard(
            title: "Library",
            icon: Icons.menu_book,
            color: Colors.brown,
          ),

          DashboardCard(
            title: "Notices",
            icon: Icons.notifications,
            color: Colors.red,
          ),

          DashboardCard(
            title: "Exams",
            icon: Icons.school,
            color: Colors.teal,
          ),

          Ebus(
            title: "Book E-Bus",
            icon: Icons.directions_bus,
            color: Colors.indigo,
          ),
        ],
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const DashboardCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: (
        
      ) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Opening $title...")),
        );
        
        },
      onLongPress: () {
        // Add navigation here
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color,
              child: Icon(icon, size: 30, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimeTable extends StatelessWidget{
  final String title;
  final IconData icon;
  final Color color;

  const TimeTable({
    super.key, 
    required this.title,
    required this.icon,
    required this.color,
  });

  @override 
  Widget build(BuildContext context){
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TimetablePage()),
        );
      },
       child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color,
              child: Icon(icon, size: 30, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
       ),
    );
  }
}


class Ebus extends StatelessWidget{
  final String title;
  final IconData icon;
  final Color color;

  const Ebus({
    super.key, 
    required this.title,
    required this.icon,
    required this.color,
  });

    Future<void> openChaloApp() async {
  final Uri chaloAppUri = Uri.parse("chalo://");
  final Uri playStoreUri = Uri.parse(
      "https://play.google.com/store/apps/details?id=app.zophop");

  if (await canLaunchUrl(chaloAppUri)) {
    await launchUrl(chaloAppUri);
  } else {
    await launchUrl(playStoreUri,
        mode: LaunchMode.externalApplication);
  }
}


  @override 
  Widget build(BuildContext context){
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: (){ 
        Navigator.push(context, 
        MaterialPageRoute(builder: (context) => const TransportPage()));
        
      },
       child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color,
              child: Icon(icon, size: 30, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
       ),
    );
  }
}