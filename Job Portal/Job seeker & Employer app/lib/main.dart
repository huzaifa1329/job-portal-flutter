import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/auth_provider.dart';
import 'providers/job_provider.dart';
import 'providers/application_provider.dart';
import 'providers/connectivity_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/job_seeker/home_screen.dart';
import 'screens/job_seeker/job_list_screen.dart';
import 'screens/job_seeker/applied_jobs_screen.dart';
import 'screens/employer/employer_dashboard.dart';
import 'screens/employer/post_job_screen.dart';
import 'screens/employer/manage_jobs_screen.dart';
import 'screens/employer/view_applications_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/edit_profile_screen.dart';

const String supabaseUrl = 'https://pmqiwxdsuasqbrutrxxk.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBtcWl3eGRzdWFzcWJydXRyeHhrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg4NTE1NjksImV4cCI6MjA5NDQyNzU2OX0.GBoT7B49bsF4gd0WYkRNTAxMv9neeZLNDFOHTYOizI0';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => JobProvider()),
        ChangeNotifierProvider(create: (_) => ApplicationProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
      ],
      child: const JobPortalApp(),
    ),
  );
}

class JobPortalApp extends StatelessWidget {
  const JobPortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgetPasswordScreen(),
        '/home': (context) => const HomeScreen(),
        '/job-list': (context) => const JobListScreen(),
        '/applied-jobs': (context) => const AppliedJobsScreen(),
        '/employer-dashboard': (context) => const EmployerDashboard(),
        '/post-job': (context) => const PostJobScreen(),
        '/manage-jobs': (context) => const ManageJobsScreen(),
        '/view-applications': (context) => const ViewApplicationsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
      },
    );
  }
}