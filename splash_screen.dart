import 'package:flutter/material.dart';
import 'package:voila_call_dummy/auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _animationCompleted = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3), // Adjust duration as needed
    );
    _animation = Tween<double>(
      begin: 0.5, // Initial scale
      end: 1.0, // Final scale
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut, // Adjust the curve as needed
      ),
    );

    // Navigate to the login screen after the splash screen animation completes
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _animationCompleted = true;
        });
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        );
      }
    });

    // Start the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set your desired background color
      body: Center(
        child: _animationCompleted
            ? SizedBox() // If animation is completed, show an empty container
            : ScaleTransition(
          scale: _animation,
          child: Image.asset(
            'assets/images/icon.png', // Replace 'your_image.png' with your image asset path
            width: 300, // Adjust size as needed
            height: 300, // Adjust size as needed
          ),
        ),
      ),
    );
  }
}