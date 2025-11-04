import 'package:flutter/material.dart';
import 'package:kaizen_pro/src/components/auth/screen/login_screen.dart';
import 'package:kaizen_pro/src/components/dashboard/screens/dashboard_screen.dart';
import 'package:kaizen_pro/src/components/dashboard/screens/home.dart';


class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String dashboard = '/dashboard';

  static final Map<String, WidgetBuilder> routes = {

    home: (context) => const LandingScreen(),
    login: (context) => const LoginScreen(), // Placeholder for LoginScreen
    dashboard: (context) => const DashboardScreen(),
  };

  
}
