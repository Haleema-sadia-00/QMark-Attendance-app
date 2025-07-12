import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase services/teacher_services.dart';
import 'teacher_attendance.dart';
import 'teacher_qr.dart';

class StudentManagementScreen extends StatefulWidget {
  final String teacherId;
  final String classId;
  final String className;
  const StudentManagementScreen({super.key, required this.teacherId, required this.classId, required this.className});
  @override
  State<StudentManagementScreen> createState() => _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  void _navigateToAttendanceSheet() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttendanceSheetScreen(
          teacherId: widget.teacherId,
          classId: widget.classId,
          className: widget.className,
        ),
      ),
    );
  }

  void _navigateToQRCode() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRCodeScreen(
          teacherId: widget.teacherId,
          classId: widget.classId,
          className: widget.className,
        ),
      ),
    );
  }

  void _showAddStudentDialog() {
    String newName = '';
    String newRoll = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Student'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              decoration: InputDecoration(hintText: 'Enter student name'),
              onChanged: (value) => newName = value,
            ),
            TextField(
              decoration: InputDecoration(hintText: 'Enter roll number'),
              onChanged: (value) => newRoll = value,
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
              if (newName.trim().isNotEmpty && newRoll.trim().isNotEmpty) {
                final studentId = FirebaseAuth.instance.currentUser?.uid ?? '';
                await teacherService.addStudent(widget.teacherId, widget.classId, studentId, newName.trim(), newRoll.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Student added!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter a name and roll number.')),
                );
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditStudentDialog(String studentId, String oldName, String oldRoll) {
    String updatedName = oldName;
    String updatedRoll = oldRoll;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Student'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              decoration: InputDecoration(hintText: 'Student name'),
              controller: TextEditingController(text: oldName),
              onChanged: (value) => updatedName = value,
            ),
            TextField(
              decoration: InputDecoration(hintText: 'Roll number'),
              controller: TextEditingController(text: oldRoll),
              onChanged: (value) => updatedRoll = value,
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
              if (updatedName.trim().isNotEmpty && updatedRoll.trim().isNotEmpty) {
                await teacherService.updateStudent(widget.teacherId, widget.classId, studentId, updatedName.trim(), updatedRoll.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Student updated!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter a name and roll number.')),
                );
              }
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _deleteStudent(String studentId) async {
    await teacherService.deleteStudent(widget.teacherId, widget.classId, studentId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Student deleted!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.teal;
    final Color accentColor = Colors.lightBlue;
    final Color textColor = Colors.black;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('Students - ${widget.className}', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code),
            tooltip: 'Go to QR Code',
            onPressed: _navigateToQRCode,
          ),
          IconButton(
            icon: Icon(Icons.assignment),
            tooltip: 'Attendance Sheet',
            onPressed: _navigateToAttendanceSheet,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.people, color: accentColor, size: 28),
                SizedBox(width: 10),
                Text(
                  'Student List',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    fontFamily: 'Poppins',
                    letterSpacing: 1.1,
                  ),
                ),
                SizedBox(width: 10),
                Icon(Icons.arrow_downward, color: accentColor, size: 22),
              ],
            ),
            SizedBox(height: 8),
            Divider(thickness: 1, color: accentColor),
            SizedBox(height: 16),
            Expanded(
              child: StreamBuilder(
                stream: teacherService.getStudents(widget.teacherId, widget.classId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data == null) {
                    return Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, color: accentColor, size: 60),
                        SizedBox(height: 10),
                        Text('No students found!', style: TextStyle(color: primaryColor, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                        SizedBox(height: 6),
                        Text('Start by adding your first student.', style: TextStyle(color: Colors.grey[600], fontSize: 16, fontFamily: 'Poppins')),
                      ],
                    ));
                  }
                  var docs = (snapshot.data as QuerySnapshot).docs;
                  docs.sort((a, b) => (a['rollNo'] ?? '').toString().compareTo((b['rollNo'] ?? '').toString()));
                  if (docs.isEmpty) {
                    return Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, color: accentColor, size: 60),
                        SizedBox(height: 10),
                        Text('No students found!', style: TextStyle(color: primaryColor, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                        SizedBox(height: 6),
                        Text('Start by adding your first student.', style: TextStyle(color: Colors.grey[600], fontSize: 16, fontFamily: 'Poppins')),
                      ],
                    ));
                  }
                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (context, index) => SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      var doc = docs[index];
                      var studentName = doc['name'] ?? '';
                      var rollNo = doc['rollNo']?.toString().padLeft(2, '0') ?? '';
                      return Card(
                        elevation: 2,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: accentColor,
                            child: Text(studentName.isNotEmpty ? studentName[0] : '?', style: TextStyle(color: primaryColor, fontFamily: 'Poppins')),
                          ),
                          title: Text(studentName, style: TextStyle(fontWeight: FontWeight.w600, color: textColor, fontFamily: 'Poppins')),
                          subtitle: Text('Roll No: $rollNo', style: TextStyle(fontFamily: 'Poppins')),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.lightBlue),
                                onPressed: () => _showEditStudentDialog(doc.id, studentName, rollNo),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteStudent(doc.id),
                              ),
                            ],
                          ),
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
        label: Text('Add Student', style: TextStyle(fontFamily: 'Poppins')),
        onPressed: _showAddStudentDialog,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
} 