import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:semproject/studentpanel.dart';
import 'package:semproject/teacherpanel.dart';

import 'adminpanel.dart';
import 'firebase services/auth_service.dart';
import 'login.dart';
import 'firebase_options.dart';
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Set persistence for web
  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          final user = snapshot.data;
          if (user == null) {
            return const LoginPage();
          }
          // Here the user data is fetched from Firestore
          return FutureBuilder<Map<String, dynamic>?>(
            future: FirebaseService().getUserData(user.uid),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const SplashScreen();
              }
              final userDoc = userSnapshot.data;
              if (userDoc == null || userDoc['approved'] != true) {
                return const LoginPage();
              }
              final role = userDoc['role'];
              if (role == 'teacher') return teacherpanel();
              if (role == 'student') return Studentpanel();
              if (role == 'admin') return const Adminpanel();
              return const LoginPage();
            },
          );
        },
      ),
    );
  }
}
