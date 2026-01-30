import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/supabase_service.dart';
import 'providers/auth_provider.dart';
import 'providers/complaint_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/student/student_dashboard.dart';
import 'screens/warden/warden_panel.dart';
import 'screens/admin/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ComplaintProvider()),
      ],
      child: MaterialApp(
        title: 'Hostel Complaint App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/student-dashboard': (context) => const StudentDashboard(),
          '/warden-panel': (context) => const WardenPanel(),
          '/admin-dashboard': (context) => const AdminDashboard(),
        },
      ),
    );
  }
}
