import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase services/teacher_services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';
import 'dart:math';

class QRCodeScreen extends StatefulWidget {
  final String teacherId;
  final String classId;
  final String className;
  const QRCodeScreen({super.key, required this.teacherId, required this.classId, required this.className});
  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  late String qrData;
  late DateTime expiryTime;
  late Timer timer;
  int secondsLeft = 180;
  bool expired = false;

  @override
  void initState() {
    super.initState();
    _generateQR();
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      setState(() {
        secondsLeft = expiryTime.difference(DateTime.now()).inSeconds;
        if (secondsLeft <= 0) {
          expired = true;
          timer.cancel();
          _markUnmarkedStudentsAbsent(); // Auto-mark absentees
        }
      });
    });
  }

  void _generateQR() {
    final now = DateTime.now();
    final random = Random().nextInt(1000000);
    expiryTime = now.add(Duration(minutes: 3));
    qrData = teacherService.generateQRData(
      widget.teacherId,
      widget.classId,
      now.toIso8601String().substring(0, 10),
      random.toString(),
      expiryTime.millisecondsSinceEpoch.toString(),
    );
    // Show SnackBar when QR is generated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('QR code generated!')),
        );
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Future<void> _markUnmarkedStudentsAbsent() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final studentsSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.teacherId)
        .collection('classes')
        .doc(widget.classId)
        .collection('students')
        .get();
    int absentCount = 0;
    for (final studentDoc in studentsSnap.docs) {
      final attendanceDoc = await studentDoc.reference.collection('attendance').doc(today).get();
      if (!attendanceDoc.exists) {
        await studentDoc.reference.collection('attendance').doc(today).set({
          'present': false,
          'status': 'Absent',
          'date': today,
        });
        absentCount++;
      }
    }
    if (mounted && absentCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$absentCount students marked absent.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.teal;
    final Color accentColor = Colors.lightBlue;
    final String today = DateTime.now().toIso8601String().substring(0, 10);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('QR Code - ${widget.className}', style: TextStyle(fontFamily: 'Font2', fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Container(
            width: 280,
            height: 360,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                expired
                  ? Icon(Icons.lock_clock, color: Colors.red, size: 60)
                  : QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 180.0,
                      backgroundColor: Colors.white,
                    ),
                SizedBox(height: 18),
                expired
                  ? Text('QR Code Expired', style: TextStyle(fontFamily: 'Font2', fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red))
                  : Text('Scan to mark attendance', style: TextStyle(fontFamily: 'Font1', fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal)),
                SizedBox(height: 8),
                Text('Class: ${widget.className}', style: TextStyle(fontFamily: 'Font2', fontSize: 15)),
                Text('Date: $today', style: TextStyle(fontFamily: 'Font1', fontSize: 14)),
                SizedBox(height: 10),
                expired
                  ? ElevatedButton.icon(
                      icon: Icon(Icons.refresh),
                      label: Text('Generate New QR'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                      onPressed: () {
                        setState(() {
                          _generateQR();
                          expired = false;
                          secondsLeft = expiryTime.difference(DateTime.now()).inSeconds;
                          timer = Timer.periodic(Duration(seconds: 1), (t) {
                            setState(() {
                              secondsLeft = expiryTime.difference(DateTime.now()).inSeconds;
                              if (secondsLeft <= 0) {
                                expired = true;
                                timer.cancel();
                              }
                            });
                          });
                        });
                      },
                    )
                  : Text('Expires in: ${secondsLeft ~/ 60}:${(secondsLeft % 60).toString().padLeft(2, '0')}', style: TextStyle(fontFamily: 'Font1', color: Colors.red, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 