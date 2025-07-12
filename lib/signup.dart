import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';

class MySignUp extends StatefulWidget {
  const MySignUp({super.key});

  @override
  State<MySignUp> createState() => _MySignUpState();
}

class _MySignUpState extends State<MySignUp> {
  bool _obscureText = true;
  String selectedRole = 'Student';
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void handleSignup() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Please fill all required fields")),
      );
      return;
    }

    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': name,
        'email': email,
        'role': selectedRole.toLowerCase(),
        'approved': false,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Signup successful. Awaiting approval.")),
      );

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: Colors.teal,
                      fontFamily: 'Font2',
                    ),
                  ),
                  SizedBox(height: 80),
                  decoratedField(
                    controller: nameController,
                    hint: 'Full Name',
                  ),
                  SizedBox(height: 25),
                  decoratedField(
                    controller: emailController,
                    hint: 'Email',
                  ),
                  SizedBox(height: 25),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(2, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text("Select Role:",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['student', 'teacher'].map((role) {
                      return Row(
                        children: [
                          Radio<String>(
                            value: role,
                            groupValue: selectedRole,
                            onChanged: (value) =>
                                setState(() => selectedRole = value!),
                          ),
                          Text(role[0].toUpperCase() + role.substring(1)),
                        ],
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 15),
                  SizedBox(height: 35),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: Colors.lightBlue,
                        ),
                      ),
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.teal,
                        child: IconButton(
                          onPressed: handleSignup,
                          icon:
                          Icon(Icons.arrow_forward, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget decoratedField({required TextEditingController controller, required String hint}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(2, 6),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
    );
  }
}
