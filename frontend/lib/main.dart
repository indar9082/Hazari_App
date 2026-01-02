// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/labour_dashboard.dart';
import 'screens/contractor_dashboard.dart';
import 'screens/attendance_history.dart';
import 'screens/leave_request_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/register_screen.dart';
import 'screens/add_labour_screen.dart';
import 'screens/forgot_password_screen.dart';




void main() {
  runApp(HazariApp());
}

class HazariApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hazari - Labour Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/labour_dashboard': (context) => LabourDashboard(),
        '/contractor_dashboard': (context) => ContractorDashboard(),  // ✅ ADD
        '/attendance_history': (context) => AttendanceHistory(),
        '/request_leave': (context) => const LeaveRequestScreen(),
        '/payment_screen': (context) => PaymentScreen(),
        '/add_labour': (context) => const AddLabourScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),

      },

    );
  }
}
