import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'adminpanel.dart';
import 'signup.dart';
import 'studentpanel.dart';
import 'teacherpanel.dart' hide Adminpanel, Studentpanel;
import 'about.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State createState() => _LoginPageState();
}

class _LoginPageState extends State {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  String selectedRole = 'teacher';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  void _resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset link sent to $email')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }


  void handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty) {
      showError('Please enter your email.');
      return;
    }
    if (password.isEmpty) {
      showError('Please enter your password.');
      return;
    }
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      final DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(userCredential.user!.uid).get();

      if (!userDoc.exists) {
        showError("User record not found in Firestore.");
        return;
      }

      final role = userDoc['role'];
      final approved = userDoc['approved'];

      if (!approved) {
        showError("Your account is not approved yet.");
        return;
      }

      if (role != selectedRole) {
        showError("Incorrect role selected.");
        return;
      }

      if (role == 'teacher') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => teacherpanel()));
      } else if (role == 'student') {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) =>  Studentpanel()));
      } else if (role == 'admin') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Adminpanel()));
      }
    } catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.contains('user-not-found')) {
        showError('No user found for this email.');
      } else if (errorMsg.contains('wrong-password')) {
        showError('Incorrect password. Please try again.');
      } else if (errorMsg.contains('network-request-failed')) {
        showError('Network error. Please check your connection.');
      } else {
        showError('Login failed: $errorMsg');
      }
    }
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage('assets/images/1.jpeg'), fit: BoxFit.cover),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 1, sigmaY: 0),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.info_outline, color: Colors.teal),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => AboutScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 50),
                      Text(
                        'Smart\nAttendance Portal',
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            color: Colors.teal,
                            fontFamily: 'font2'),
                      ),
                      SizedBox(height: 80),
                      buildInputField('Email', _emailController),
                      SizedBox(height: 25),
                      buildPasswordField(),
                      SizedBox(height: 20),
                      Text('Select Role:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: ['teacher', 'student', 'admin'].map((role) {
                          return Row(
                            children: [
                              Radio<String>(
                                value: role,
                                groupValue: selectedRole,
                                onChanged: (value) => setState(() => selectedRole = value!),
                              ),
                              Text(role),
                            ],
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 25),
                      Center(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            minimumSize: Size(double.infinity, 50),
                          ),
                          label: Text('Login'),
                          onPressed: handleLogin,
                          icon: Icon(Icons.login),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context, MaterialPageRoute(builder: (context) => MySignUp()));
                            },
                            child: Text(
                              'Create Account',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontSize: 18,
                                color: Colors.lightBlue,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              if (_emailController.text.isNotEmpty) {
                                _resetPassword(_emailController.text.trim());
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Please enter your email first')),
                                );
                              }
                            },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontSize: 16,
                                color: Colors.lightBlue,
                              ),
                            ),
                          ),
                        ],
                      ),

                    ], // Column children
                  ), // Column
                ), // Padding
              ), // SingleChildScrollView
            ],
          ),
        ), // Scaffold
      ), // BackdropFilter
    ); // Container
  }

  Widget buildInputField(String hint, TextEditingController controller) {
    return Container(
      decoration: buildBoxDecoration(),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
    );
  }

  Widget buildPasswordField() {
    return Container(
      decoration: buildBoxDecoration(),
      child: TextField(
        obscureText: _obscureText,
        controller: _passwordController,
        decoration: InputDecoration(
          hintText: 'Password',
          suffixIcon: IconButton(
            icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _obscureText = !_obscureText),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
    );
  }

  BoxDecoration buildBoxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(2, 6))],
    );
  }
}
