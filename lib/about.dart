import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About', style: TextStyle(fontFamily: 'Poppins')),
        backgroundColor: const Color(0xFF008080),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo
              CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage('assets/images/1.jpeg'),
              ),
              const SizedBox(height: 24),
              const Text(
                'Smart Attendance App',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Version 1.0.0',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              const Text(
                'An Attendance management app using Flutter and Firebase.\n\n'
                'Developed by:\n'
                'Halima Sadia (22-ARID-5141)\n'
                'Mariyam Norren (22-ARID-5145)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 16),
              const Text(
                '© 2024 All rights reserved.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 