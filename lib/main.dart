import 'package:flutter/material.dart';
import 'package:voila_call_dummy/auth/login_screen.dart';
import 'package:voila_call_dummy/auth/dashboard_screen.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voila_Call Dummy',
      theme: ThemeData(
        primaryColor: Color(0xFF5E17EB),
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/login', // Set the initial route to '/login'
      routes: {
        '/login': (context) => LoginScreen(),
        '/dashboard': (context) => DashboardScreen(username: ''), // Provide a dummy username
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Text('Error: Route not found'),
            ),
          ),
        );
      },
    );
  }
}
