import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Splash will show for 15 seconds
    Future.delayed(const Duration(seconds: 15), () {
      // TODO: Replace with your actual navigation logic
      Navigator.of(context).pushReplacementNamed('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF008080),
              Color(0xFF26A69A),
              Color(0xFFB2DFDB),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo or icon
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.school, color: Color(0xFF008080), size: 70),
                ),
              ),
              const SizedBox(height: 36),
              // App name
              Text(
                'Smart Attendance',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  letterSpacing: 1.2,
                  shadows: [
                    Shadow(
                      blurRadius: 8,
                      color: Colors.black45,
                      offset: Offset(2, 3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Halima Sadia 22-ARID-5141',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.1,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Mariyam Norren 22-ARID-5145',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.05,
                ),
              ),
              const SizedBox(height: 18),
              // Loading indicator
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 4.5,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 