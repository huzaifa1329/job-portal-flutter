import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Job Portal';
  
  static const List<String> jobTypes = [
    'Full Time',
    'Part Time',
    'Remote',
    'Contract',
    'Internship'
  ];
  
  static const List<String> experienceLevels = [
    'Entry Level (0-1 years)',
    'Intermediate (2-4 years)',
    'Senior (5+ years)'
  ];
  
  static const List<String> salaryRanges = [
    'Negotiable',
    '\$20,000 - \$30,000',
    '\$30,000 - \$40,000',
    '\$40,000 - \$50,000',
    '\$50,000 - \$60,000',
    '\$60,000+'
  ];
}

class AppColors {
  static const Color primary = Colors.blue;
  static const Color secondary = Colors.blueAccent;
  static const Color success = Colors.green;
  static const Color error = Colors.red;
  static const Color warning = Colors.orange;
  static const Color background = Colors.white;
}

class AppStyles {
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );
  
  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.black54,
  );
  
  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    color: Colors.black87,
  );
  
  static const TextStyle captionStyle = TextStyle(
    fontSize: 12,
    color: Colors.black54,
  );
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

class AppDurations {
  static const Duration short = Duration(milliseconds: 300);
  static const Duration medium = Duration(milliseconds: 500);
  static const Duration long = Duration(milliseconds: 800);
}