import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/admin_login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://pmqiwxdsuasqbrutrxxk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBtcWl3eGRzdWFzcWJydXRyeHhrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg4NTE1NjksImV4cCI6MjA5NDQyNzU2OX0.GBoT7B49bsF4gd0WYkRNTAxMv9neeZLNDFOHTYOizI0',
  );
  
  runApp(const MyAdminApp());
}

class MyAdminApp extends StatelessWidget {
  const MyAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  title: 'Admin Dashboard',
  debugShowCheckedModeBanner: false,
  theme: ThemeData(
    primarySwatch: Colors.blue,
  ),

  initialRoute: '/',

  routes: {
    '/': (context) => const AdminLoginScreen(),

    '/dashboard': (context) => const DashboardScreen(),
  },
);
  }
}