import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:semproject/teacherpanel.dart';
import 'login.dart';
import 'firebase services/student_services.dart';
import 'firebase services/teacher_services.dart';

class Studentpanel extends StatefulWidget {
  const Studentpanel({super.key});

  @override
  State<Studentpanel> createState() => _StudentpanelState();
}

class _StudentpanelState extends State<Studentpanel> {
  String? teacherId;
  String? classId;
  String? className;
  String? studentId;
  String? studentName;
  bool loading = true;
  String? scanResult;

  @override
  void initState() {
    super.initState();
    _fetchStudentInfo();
  }

  Future<void> _fetchStudentInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    print('Current user UID: ${user?.uid}');
    if (user == null) {
      setState(() { loading = false; });
      return;
    }
    studentId = user.uid;
    // Find the teacherId and classId where this student is enrolled
    final teachersSnap = await FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'teacher').get();
    for (var teacherDoc in teachersSnap.docs) {
      final classesSnap = await teacherDoc.reference.collection('classes').get();
      for (var classDoc in classesSnap.docs) {
        final studentsSnap = await classDoc.reference.collection('students').get();
        for (var studentDoc in studentsSnap.docs) {
          print('Checking studentDoc.id: ${studentDoc.id}');
          if (studentDoc.id == studentId) {
            print('Found enrolled student!');
            teacherId = teacherDoc.id;
            classId = classDoc.id;
            className = classDoc['name'] ?? classId;
            studentName = studentDoc['name'] ?? '';
            setState(() { loading = false; });
            return;
          }
        }
      }
    }
    print('Student not found in any class.');
    setState(() { loading = false; });
  }

  void _scanQRAndMarkAttendance() async {
    String? qrData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text('Scan QR')),
          body: MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                Navigator.of(context).pop(barcodes.first.rawValue);
              }
            },
          ),
        ),
      ),
    );
    if (qrData != null && studentId != null && teacherId != null) {
      String? result = await teacherService.scanAndMarkAttendance(qrData, studentId!, teacherId!);
      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Attendance marked!')),
        );
      } else if (result == 'already_marked') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Attendance already marked for today!')),
        );
      } else if (result == 'QR Expired') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('QR code expired! Please ask your teacher for a new one.')),
        );
      } else if (result == 'This QR is not for your teacher!') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('This QR is not for your teacher!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $result')),
        );
      }
      setState(() { scanResult = result; });
    }
  }

  void _showChangePasswordDialog(BuildContext context) {
    final _currentPasswordController = TextEditingController();
    final _newPasswordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Current Password'),
            ),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'New Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              final currentPassword = _currentPasswordController.text.trim();
              final newPassword = _newPasswordController.text.trim();
              if (user != null && currentPassword.isNotEmpty && newPassword.isNotEmpty) {
                try {
                  final cred = EmailAuthProvider.credential(email: user.email!, password: currentPassword);
                  await user.reauthenticateWithCredential(cred);
                  await user.updatePassword(newPassword);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Password changed successfully!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to change password: $e')),
                  );
                }
              }
            },
            child: Text('Change'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Drawer building: ' + (studentName ?? 'Student'));
    final Color primaryColor = const Color(0xFF008080);
    final Color accentColor = const Color(0xFF4FC3F7);
    final Color presentColor = const Color(0xFF4CAF50);
    final Color absentColor = const Color(0xFFE53935);
    final Color backgroundColor = const Color(0xFFF9F9F9);
    final Color textColor = const Color(0xFF333333);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Student Dashboard', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.teal, size: 36),
                  ),
                  SizedBox(height: 12),
                  Text(studentName ?? 'Student', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                  Text(FirebaseAuth.instance.currentUser?.email ?? '', style: TextStyle(color: Colors.white70, fontFamily: 'Poppins')),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.lock),
              title: Text('Change Password', style: TextStyle(fontFamily: 'Poppins')),
              onTap: () {
                Navigator.pop(context);
                _showChangePasswordDialog(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout', style: TextStyle(fontFamily: 'Poppins')),
              onTap: () async {
                Navigator.pop(context);
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Logout'),
                    content: Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text('Logout'),
                      ),
                    ],
                  ),
                );
                if (shouldLogout == true) {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                    (route) => false,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Logged out!')),
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: loading
        ? Center(child: CircularProgressIndicator())
        : (teacherId == null || classId == null || studentId == null)
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('You are not enrolled in any class.'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    child: Text('Join Class'),
                    onPressed: () async {
                      String? classCode = await showDialog<String>(
                        context: context,
                        builder: (context) {
                          String input = '';
                          return AlertDialog(
                            title: Text('Enter Class Code'),
                            content: TextField(
                              onChanged: (val) => input = val,
                              decoration: InputDecoration(hintText: 'Class Code'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, null),
                                child: Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, input),
                                child: Text('Join'),
                              ),
                            ],
                          );
                        },
                      );
                      if (classCode != null && classCode.trim().isNotEmpty) {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          final result = await studentService.joinClassByCode(user.uid, user.displayName ?? 'Student', classCode.trim());
                          if (result == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Joined class!')),
                            );
                            await _fetchStudentInfo();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(result)),
                            );
                          }
                        }
                      }
                    },
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: primaryColor,
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person, color: Color(0xFF008080), size: 36),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Welcome, ${studentName ?? 'Student'}!', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                                const SizedBox(height: 6),
                                Text('Class: ${className ?? classId ?? ''}', style: const TextStyle(color: Colors.white70, fontSize: 16, fontFamily: 'Poppins')),
                                Text(FirebaseAuth.instance.currentUser?.email ?? '', style: const TextStyle(color: Colors.white70, fontSize: 15, fontFamily: 'Poppins')),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Attendance Summary Card (real data)
                  StreamBuilder(
                    stream: studentService.getAttendanceStream(teacherId!, classId!, studentId!),
                    builder: (context, snapshot) {
                      int totalDays = 0;
                      int presentDays = 0;
                      int absentDays = 0;
                      double percent = 0;
                      if (snapshot.hasData && (snapshot.data as QuerySnapshot).docs.isNotEmpty) {
                        final docs = (snapshot.data as QuerySnapshot).docs;
                        totalDays = docs.length;
                        for (var doc in docs) {
                          final data = doc.data() as Map<String, dynamic>;
                          final status = data['status'] ?? (data['present'] == true ? 'Present' : 'Absent');
                          if (status == 'Present') presentDays++;
                          if (status == 'Absent') absentDays++;
                        }
                        percent = totalDays == 0 ? 0 : (presentDays / totalDays) * 100;
                      }
                      return Card(
                        color: accentColor.withOpacity(0.15),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  const Text('Total', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                                  Text('$totalDays', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: primaryColor, fontSize: 18)),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text('Present', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                                  Text('$presentDays', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: presentColor, fontSize: 18)),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text('Absent', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                                  Text('$absentDays', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: absentColor, fontSize: 18)),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text('Percent', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width: 36,
                                        height: 36,
                                        child: CircularProgressIndicator(
                                          value: percent / 100,
                                          backgroundColor: Colors.grey[300],
                                          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                          strokeWidth: 5,
                                        ),
                                      ),
                                      Text('${percent.toStringAsFixed(0)}%', style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13)),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 24,
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Attendance History',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                          fontFamily: 'Poppins',
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.history, color: accentColor, size: 22),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Card(
                      color: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        child: StreamBuilder(
                          stream: studentService.getAttendanceStream(teacherId!, classId!, studentId!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            if (!snapshot.hasData || (snapshot.data as QuerySnapshot).docs.isEmpty) {
                              return Center(child: Text('No attendance records found.', style: TextStyle(fontFamily: 'Poppins')));
                            }
                            final docs = (snapshot.data as QuerySnapshot).docs;
                            return ListView.separated(
                              itemCount: docs.length,
                              separatorBuilder: (context, index) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final record = docs[index].data() as Map<String, dynamic>;
                                final date = record['date'] ?? '';
                                final status = record['status'] ?? (record['present'] == true ? 'Present' : 'Absent');
                                Color badgeColor = status == 'Present' ? presentColor : absentColor;
                                return ListTile(
                                  leading: Icon(
                                    status == 'Present' ? Icons.check_circle : Icons.cancel,
                                    color: badgeColor,
                                  ),
                                  title: Text(date, style: TextStyle(fontFamily: 'Poppins', color: textColor)),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: badgeColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      status,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18),
                        elevation: 3,
                      ),
                      icon: const Icon(Icons.qr_code_scanner, size: 28),
                      label: const Text('Scan QR to Mark Attendance'),
                      onPressed: _scanQRAndMarkAttendance,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
