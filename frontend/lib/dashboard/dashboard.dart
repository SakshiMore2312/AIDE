import 'package:flutter/material.dart';
import 'education_page.dart';
import 'medical_page.dart';
import 'stay_pg_page.dart';
import 'profile_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    EducationPage(),
    MedicalPage(),
    StayPGPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      
      appBar: AppBar(
        title: const Text("AIDE", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),

      body: pages[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        setState(() {
          currentIndex = index;
        });
      },

      type: BottomNavigationBarType.fixed,

      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      showUnselectedLabels: true,

      elevation: 10,

      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.school),
          label: "Education",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_hospital),
          label: "Medical",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Stay/PG",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profile",
        ),
      ],
    ),
    );
  }
}
