import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a class with a unique code
  Future<void> addClassWithCode(String teacherId, String className, String classCode) async {
    await _firestore.collection('users').doc(teacherId).collection('classes').add({
      'name': className,
      'classCode': classCode,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Get all classes for a teacher
  Stream<QuerySnapshot> getClasses(String teacherId) {
    return _firestore.collection('users').doc(teacherId).collection('classes').snapshots();
  }

  // Update class name
  Future<void> updateClass(String teacherId, String classId, String newName) async {
    await _firestore.collection('users').doc(teacherId).collection('classes').doc(classId).update({'name': newName});
  }

  // Delete a class (and all students and their attendance)
  Future<void> deleteClass(String teacherId, String classId) async {
    final classRef = _firestore.collection('users').doc(teacherId).collection('classes').doc(classId);
    final studentsSnap = await classRef.collection('students').get();
    for (var studentDoc in studentsSnap.docs) {
      final attendanceSnap = await studentDoc.reference.collection('attendance').get();
      for (var attDoc in attendanceSnap.docs) {
        await attDoc.reference.delete();
      }
      await studentDoc.reference.delete();
    }
    await classRef.delete();
  }

  // Add a student to a class
  Future<void> addStudent(String teacherId, String classId, String studentId, String name, String rollNo) async {
    await _firestore.collection('users').doc(teacherId).collection('classes').doc(classId).collection('students').doc(studentId).set({
      'name': name,
      'rollNo': rollNo,
    });
    await _reassignRollNumbers(teacherId, classId);
  }

  // Get all students in a class
  Stream<QuerySnapshot> getStudents(String teacherId, String classId) {
    return _firestore.collection('users').doc(teacherId).collection('classes').doc(classId).collection('students').snapshots();
  }

  // Update student info
  Future<void> updateStudent(String teacherId, String classId, String studentId, String name, String rollNo) async {
    await _firestore.collection('users').doc(teacherId).collection('classes').doc(classId).collection('students').doc(studentId).update({
      'name': name,
      'rollNo': rollNo,
    });
    await _reassignRollNumbers(teacherId, classId);
  }

  // Delete a student from a class (and their attendance)
  Future<void> deleteStudent(String teacherId, String classId, String studentId) async {
    final studentRef = _firestore.collection('users').doc(teacherId).collection('classes').doc(classId).collection('students').doc(studentId);
    final attendanceSnap = await studentRef.collection('attendance').get();
    for (var doc in attendanceSnap.docs) {
      await doc.reference.delete();
    }
    await studentRef.delete();
  }

  // Mark attendance for a student
  Future<void> markAttendance(String teacherId, String classId, String studentId, String date, bool present) async {
    await _firestore.collection('users').doc(teacherId)
      .collection('classes').doc(classId)
      .collection('students').doc(studentId)
      .collection('attendance').doc(date).set({
        'present': present,
        'date': date,
      });
  }

  // Get attendance stream for a student
  Stream<QuerySnapshot> getAttendance(String teacherId, String classId, String studentId) {
    return _firestore.collection('users').doc(teacherId)
      .collection('classes').doc(classId)
      .collection('students').doc(studentId)
      .collection('attendance').snapshots();
  }

  // Update attendance
  Future<void> updateAttendance(String teacherId, String classId, String studentId, String date, bool present) async {
    await _firestore.collection('users').doc(teacherId)
      .collection('classes').doc(classId)
      .collection('students').doc(studentId)
      .collection('attendance').doc(date).update({
        'present': present,
      });
  }

  // Delete attendance
  Future<void> deleteAttendance(String teacherId, String classId, String studentId, String date) async {
    await _firestore.collection('users').doc(teacherId)
      .collection('classes').doc(classId)
      .collection('students').doc(studentId)
      .collection('attendance').doc(date).delete();
  }

  // Generate QR data for attendance
  String generateQRData(String teacherId, String classId, String date, String random, String expiry) {
    return '$teacherId|$classId|$date|$random|$expiry';
  }

  // Student scans QR and calls this to mark attendance
  Future<String?> scanAndMarkAttendance(String qrData, String studentId, String myTeacherId) async {
    try {
      var parts = qrData.split('|');
      if (parts.length != 5) return 'Invalid QR';
      String teacherId = parts[0];
      String classId = parts[1];
      String date = parts[2];
      int expiry = int.tryParse(parts[4]) ?? 0;
      if (DateTime.now().millisecondsSinceEpoch > expiry) return 'QR Expired';
      if (teacherId != myTeacherId) return 'This QR is not for your teacher!';
      // Check if already marked
      final attendanceDoc = await _firestore.collection('users').doc(teacherId)
        .collection('classes').doc(classId)
        .collection('students').doc(studentId)
        .collection('attendance').doc(date).get();
      if (attendanceDoc.exists) {
        return 'already_marked';
      }
      await markAttendance(teacherId, classId, studentId, date, true);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Helper: Reassign roll numbers alphabetically
  Future<void> _reassignRollNumbers(String teacherId, String classId) async {
    final studentsSnap = await _firestore.collection('users').doc(teacherId).collection('classes').doc(classId).collection('students').get();
    final students = studentsSnap.docs.toList();
    students.sort((a, b) => (a['name'] ?? '').toString().compareTo((b['name'] ?? '').toString()));
    int roll = 1;
    for (final doc in students) {
      await doc.reference.update({'rollNo': roll.toString().padLeft(2, '0')});
      roll++;
    }
  }
}

final TeacherService teacherService = TeacherService(); 