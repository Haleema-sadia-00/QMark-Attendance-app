import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase services/auth_service.dart';
import 'firebase services/teacher_services.dart';
import 'login.dart';
import 'teacher_students.dart';
import 'teacher_attendance.dart';
import 'teacher_qr.dart';

class teacherpanel extends StatefulWidget {
  @override
  State<teacherpanel> createState() => _teacherpanelState();
}

class _teacherpanelState extends State<teacherpanel> {
  final String? teacherId = FirebaseAuth.instance.currentUser?.uid;
  String? teacherName;

  @override
  void initState() {
    super.initState();
    _fetchTeacherName();
  }

  // This function fetches the teacher's name from Firestore and sets it
  void _fetchTeacherName() async {
    if (teacherId != null) {
      final data = await firebaseService.getUserData(teacherId!);
      setState(() {
        teacherName = data?['name'] ?? 'Teacher';
      });
    }
  }

  // This function navigates to the student management screen for a class
  void _navigateToStudentManagement(String classId, String className) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentManagementScreen(
          teacherId: teacherId!,
          classId: classId,
          className: className,
        ),
      ),
    );
  }

  // This function navigates to the attendance sheet screen for a class
  void _navigateToAttendanceSheet(String classId, String className) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttendanceSheetScreen(
          teacherId: teacherId!,
          classId: classId,
          className: className,
        ),
      ),
    );
  }

  // This function navigates to the QR code screen for a class
  void _navigateToQRCode(String classId, String className) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRCodeScreen(
          teacherId: teacherId!,
          classId: classId,
          className: className,
        ),
      ),
    );
  }

  // This dialog lets the teacher add a new class
  void _showAddClassDialog() {
    String newClass = '';
    String classCode = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Class'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              decoration: InputDecoration(hintText: 'Enter class/section name'),
              onChanged: (value) => newClass = value,
            ),
            TextField(
              decoration: InputDecoration(hintText: 'Enter class code (unique)'),
              onChanged: (value) => classCode = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
            onPressed: () async {
              if (newClass.trim().isNotEmpty && classCode.trim().isNotEmpty && teacherId != null) {
                await teacherService.addClassWithCode(teacherId!, newClass.trim(), classCode.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Class added!')),
                );
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  // This dialog lets the teacher edit a class name
  void _showEditClassDialog(String classId, String oldName) {
    String updatedName = oldName;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Class'),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(hintText: 'Class name'),
          controller: TextEditingController(text: oldName),
          onChanged: (value) => updatedName = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
            onPressed: () async {
              if (updatedName.trim().isNotEmpty && teacherId != null) {
                await teacherService.updateClass(teacherId!, classId, updatedName.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Class updated!')),
                );
              }
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  // This function deletes a class from Firestore
  void _deleteClass(String classId) async {
    if (teacherId != null) {
      await teacherService.deleteClass(teacherId!, classId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Class deleted!')),
      );
    }
  }

  // This dialog lets the teacher change their password
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
                  // Re-authenticate
                  final cred = EmailAuthProvider.credential(email: user.email!, password: currentPassword);
                  await user.reauthenticateWithCredential(cred);
                  await user.updatePassword(newPassword);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Password changed!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error changing password.')),
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(
          teacherName != null ? 'Welcome, $teacherName!' : 'Teacher Dashboard',
          style: TextStyle(fontFamily: 'Font2', fontWeight: FontWeight.bold, fontSize: 22),
        ),
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
                  Text('Teacher', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                  Text('teacher@email.com', style: TextStyle(color: Colors.white70, fontFamily: 'Poppins')),
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
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.teal,
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Icon(Icons.school, color: Colors.white, size: 40),
                    SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            teacherName != null ? 'Welcome, $teacherName!' : 'Welcome, Teacher!',
                            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Font2', letterSpacing: 1.1),
                          ),
                          SizedBox(height: 6),
                          Text('Manage your classes, students, and attendance easily.', style: TextStyle(color: Colors.white70, fontSize: 16, fontFamily: 'Font1')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 18),
            Row(
              children: [
                Icon(Icons.list_alt, color: Colors.teal, size: 28),
                SizedBox(width: 10),
                Text(
                  'Your Classes',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                    fontFamily: 'Font2',
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(width: 10),
                Icon(Icons.arrow_downward, color: Colors.lightBlue, size: 22),
              ],
            ),
            SizedBox(height: 8),
            Divider(thickness: 1, color: Colors.lightBlue),
            SizedBox(height: 16),
            Expanded(
              child: teacherId == null
                ? Center(child: Text('No teacher logged in.'))
                : StreamBuilder(
                    stream: teacherService.getClasses(teacherId!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data == null) {
                        return Center(child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline, color: Colors.lightBlue, size: 60),
                            SizedBox(height: 10),
                            Text('No classes found!', style: TextStyle(color: Colors.teal, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Font2')),
                            SizedBox(height: 6),
                            Text('Start by adding your first class.', style: TextStyle(color: Colors.grey[600], fontSize: 16, fontFamily: 'Font1')),
                          ],
                        ));
                      }
                      var docs = (snapshot.data as QuerySnapshot).docs;
                      docs.sort((a, b) => (a['name'] ?? '').toString().compareTo((b['name'] ?? '').toString()));
                      if (docs.isEmpty) {
                        return Center(child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline, color: Colors.lightBlue, size: 60),
                            SizedBox(height: 10),
                            Text('No classes found!', style: TextStyle(color: Colors.teal, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Font2')),
                            SizedBox(height: 6),
                            Text('Start by adding your first class.', style: TextStyle(color: Colors.grey[600], fontSize: 16, fontFamily: 'Font1')),
                          ],
                        ));
                      }
                      return ListView.separated(
                        itemCount: docs.length,
                        separatorBuilder: (context, index) => SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          var doc = docs[index];
                          var className = doc['name'] ?? '';
                          return Card(
                            elevation: 3,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.lightBlue,
                                child: Icon(Icons.class_, color: Colors.teal),
                              ),
                              title: Text(className, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black, fontFamily: 'Font2', fontSize: 18)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.lightBlue),
                                    onPressed: () => _showEditClassDialog(doc.id, className),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteClass(doc.id),
                                  ),
                                  Icon(Icons.arrow_forward_ios, color: Colors.teal),
                                ],
                              ),
                              onTap: () => _navigateToStudentManagement(doc.id, className),
                            ),
                          );
                        },
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
        icon: Icon(Icons.add),
        label: Text('Add Class', style: TextStyle(fontFamily: 'Font2')),
        onPressed: _showAddClassDialog,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
