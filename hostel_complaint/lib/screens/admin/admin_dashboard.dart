import 'package:flutter/material.dart';
import '../../core/sky_widgets.dart';
import '../../core/theme.dart';
import 'analytics_hub.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const AnalyticsHub(),
    const Center(child: Text('Complaints List View')),
    const Center(child: Text('Reports View')),
    const Center(child: Text('Users View')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SkyBackground(
        child: IndexedStack(
          index: _currentIndex,
          children: _tabs,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.primaryBlue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Complaints'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
        ],
      ),
    );
  }
}
