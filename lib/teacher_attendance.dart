import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase services/teacher_services.dart';

class AttendanceSheetScreen extends StatefulWidget {
  final String teacherId;
  final String classId;
  final String className;
  const AttendanceSheetScreen({super.key, required this.teacherId, required this.classId, required this.className});
  @override
  State<AttendanceSheetScreen> createState() => _AttendanceSheetScreenState();
}

class _AttendanceSheetScreenState extends State<AttendanceSheetScreen> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.teal;
    final Color accentColor = Colors.lightBlue;
    final Color presentColor = Colors.green;
    final Color absentColor = Colors.red;
    final Color textColor = Colors.black;
    String formattedDate = selectedDate.toIso8601String().substring(0, 10);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('Attendance Sheet - 24{widget.className}', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Picker
            Row(
              children: [
                Text('Select Date: ', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton.icon(
                  icon: Icon(Icons.calendar_today, color: accentColor),
                  label: Text(formattedDate, style: TextStyle(fontFamily: 'Poppins', color: accentColor)),
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2023, 1, 1),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder(
                stream: teacherService.getStudents(widget.teacherId, widget.classId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data == null) {
                    return Center(child: Text('No students found.'));
                  }
                  var studentDocs = (snapshot.data as QuerySnapshot).docs;
                  studentDocs.sort((a, b) => (a['rollNo'] ?? '').toString().compareTo((b['rollNo'] ?? '').toString()));
                  if (studentDocs.isEmpty) {
                    return Center(child: Text('No students found.', style: TextStyle(color: Colors.grey[600], fontSize: 16, fontFamily: 'Poppins')));
                  }
                  return ListView.separated(
                    itemCount: studentDocs.length,
                    separatorBuilder: (context, index) => SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      var studentDoc = studentDocs[index];
                      var studentName = studentDoc['name'] ?? '';
                      var rollNo = studentDoc['rollNo']?.toString().padLeft(2, '0') ?? '';
                      // Here the students' attendance is fetched from Firestore (teacherService.getStudents)
                      return FutureBuilder<DocumentSnapshot>(
                        future: studentDoc.reference.collection('attendance').doc(formattedDate).get(),
                        builder: (context, attSnap) {
                          bool isPresent = false;
                          bool hasRecord = false;
                          if (attSnap.hasData && attSnap.data != null && attSnap.data!.exists) {
                            hasRecord = true;
                            var data = attSnap.data!.data() as Map<String, dynamic>;
                            isPresent = data['present'] == true || data['status'] == 'Present';
                          }
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
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isPresent ? presentColor : absentColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      isPresent ? 'Present' : 'Absent',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Mark Present button
                                  IconButton(
                                    icon: Icon(Icons.check_circle, color: presentColor),
                                    tooltip: 'Mark Present',
                                    onPressed: () async {
                                      try {
                                        await studentDoc.reference.collection('attendance').doc(formattedDate).set({
                                          'present': true,
                                          'status': 'Present',
                                          'date': formattedDate,
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Attendance marked as present.')),
                                        );
                                        setState(() {}); // Refresh UI
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error marking attendance.')),
                                        );
                                      }
                                    },
                                  ),
                                  // Mark Absent button
                                  IconButton(
                                    icon: Icon(Icons.cancel, color: absentColor),
                                    tooltip: 'Mark Absent',
                                    onPressed: () async {
                                      try {
                                        await studentDoc.reference.collection('attendance').doc(formattedDate).set({
                                          'present': false,
                                          'status': 'Absent',
                                          'date': formattedDate,
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Attendance marked as absent.')),
                                        );
                                        setState(() {}); // Refresh UI
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error marking attendance.')),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 