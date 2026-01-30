import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/sky_widgets.dart';
import '../../core/theme.dart';
import 'home_tab.dart';
import 'add_complaint_screen.dart';
import 'inbox_screen.dart';
import 'my_reports_screen.dart';
import 'profile_tab.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const HomeTab(),
    const AddComplaintScreen(), 
    const InboxScreen(),
    const MyReportsScreen(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // For transparent bottom bar effect if needed
      body: SkyBackground(
        child: IndexedStack(
           index: _currentIndex,
           children: _tabs,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(0, Icons.grid_view_rounded, 'Home'),
                _buildNavItem(1, Icons.add_circle_rounded, 'Report'),
                _buildNavItem(2, Icons.mail_rounded, 'Inbox'),
                _buildNavItem(3, Icons.history_rounded, 'History'),
                _buildNavItem(4, Icons.person_rounded, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: 300.ms,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.lightBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
            ),
            if (isSelected)
              Text(
                 label,
                 style: const TextStyle(
                   fontSize: 10, 
                   color: AppTheme.primaryBlue,
                   fontWeight: FontWeight.bold,
                 ),
              ).animate().fadeIn(),
          ],
        ),
      ),
    );
  }
}
