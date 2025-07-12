import 'package:cloud_firestore/cloud_firestore.dart';

class StudentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Here the attendance stream is fetched from Firestore
  Stream<QuerySnapshot> getAttendanceStream(String teacherId, String classId, String studentId) {
    return _firestore
      .collection('users')
      .doc(teacherId)
      .collection('classes')
      .doc(classId)
      .collection('students')
      .doc(studentId)
      .collection('attendance')
      .orderBy('date', descending: true)
      .snapshots();
  }

  // Here the student joins a class using a code (joinClassByCode)
  Future<String?> joinClassByCode(String studentId, String name, String classCode) async {
    print('Trying to join class with code: $classCode');
    
    // Get all users who are teachers
    final teachersSnap = await _firestore.collection('users').where('role', isEqualTo: 'teacher').get();
    print('Teachers fetched: \'${teachersSnap.docs.length}\'');
    
    for (var doc in teachersSnap.docs) {
      print('Teacher ID: \'${doc.id}\'');
    }
    
    // Fetch the student's real name from their user profile
    final studentProfile = await _firestore.collection('users').doc(studentId).get();
    final studentName = studentProfile.data()?['name'] ?? name;
    
    for (var teacherDoc in teachersSnap.docs) {
      print('Checking teacher: \'${teacherDoc.id}\'');
      final classesSnap = await teacherDoc.reference.collection('classes').get();
      print('Total classes for this teacher: \'${classesSnap.docs.length}\'');
      
      for (var classDoc in classesSnap.docs) {
        print('Checking class: \'${classDoc.id}\', code: \'${classDoc['classCode']}\'');
        if ((classDoc['classCode'] ?? '') == classCode.trim()) {
          // Assign the lowest available roll number
          final studentsSnap = await classDoc.reference.collection('students').get();
          final existingRollNos = studentsSnap.docs
              .map((doc) => int.tryParse(doc['rollNo'] ?? ''))
              .where((num) => num != null)
              .toList()
            ..sort();
          int rollNo = 1;
          for (final num in existingRollNos) {
            if (num == rollNo) {
              rollNo++;
            } else {
              break;
            }
          }
          await classDoc.reference.collection('students').doc(studentId).set({
            'name': studentName,
            'rollNo': rollNo.toString(),
          });
          print('Student added to: ${classDoc.reference.path}/students/$studentId');
          return null; // Success
        }
      }
    }
    print('Class code not found!');
    return 'Class code not found!';
  }

  // Delete a student and all their attendance records
  Future<void> deleteStudentWithAttendance(String teacherId, String classId, String studentId) async {
    final studentRef = _firestore.collection('users').doc(teacherId).collection('classes').doc(classId).collection('students').doc(studentId);
    final attendanceSnap = await studentRef.collection('attendance').get();
    for (var doc in attendanceSnap.docs) {
      await doc.reference.delete();
    }
    await studentRef.delete();
  }
}

final studentService = StudentService(); 