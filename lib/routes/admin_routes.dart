import 'package:flutter/material.dart';
import 'package:mygate_coepd/screens/admin/admin_dashboard_screen.dart';

class AdminRoutes {
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      // Admin Dashboard
      '/admin-dashboard': (context) => const AdminDashboardScreen(),
    };
  }
}