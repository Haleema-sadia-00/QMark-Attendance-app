import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase services/teacher_services.dart';

class TeacherClassesScreen extends StatefulWidget {
  final String teacherId;
  final String? teacherName;
  const TeacherClassesScreen({super.key, required this.teacherId, this.teacherName});
  @override
  State<TeacherClassesScreen> createState() => _TeacherClassesScreenState();
}

class _TeacherClassesScreenState extends State<TeacherClassesScreen> {
  void _navigateToStudentManagement(String classId, String className) {
    // Navigation logic here (import StudentManagementScreen from teacher_students.dart)
  }

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
              if (newClass.trim().isNotEmpty && classCode.trim().isNotEmpty && widget.teacherId.isNotEmpty) {
                await teacherService.addClassWithCode(widget.teacherId, newClass.trim(), classCode.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Class added successfully!')),
                );
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

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
              if (updatedName.trim().isNotEmpty && widget.teacherId.isNotEmpty) {
                await teacherService.updateClass(widget.teacherId, classId, updatedName.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Class updated successfully!')),
                );
              }
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _deleteClass(String classId) async {
    if (widget.teacherId.isNotEmpty) {
      await teacherService.deleteClass(widget.teacherId, classId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Class deleted!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.teal;
    final Color accentColor = Colors.lightBlue;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          widget.teacherName != null ? 'Welcome, ${widget.teacherName}!' : 'Teacher Dashboard',
          style: TextStyle(fontFamily: 'Font2', fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
              child: StreamBuilder(
                stream: teacherService.getClasses(widget.teacherId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data == null) {
                    return Center(child: Text('No classes found!'));
                  }
                  var docs = (snapshot.data as QuerySnapshot).docs;
                  docs.sort((a, b) => (a['name'] ?? '').toString().compareTo((b['name'] ?? '').toString()));
                  if (docs.isEmpty) {
                    return Center(child: Text('No classes found!', style: TextStyle(color: Colors.teal, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Font2')));
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