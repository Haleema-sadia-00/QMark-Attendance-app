import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Sign UP services
Future<String?> signUpUser(String email , String password , String role)async{
 try{
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
    );

    await _firestore.collection('users').doc(userCredential.user!.uid).
  set({
      'email' : email,
      'role': role.toLowerCase(),
      'approved' : false,
    });

    return null;
}
 catch(e)
 {
   return e.toString();
 }
}

  // Login
  Future<Map<String, dynamic>?> loginAndCheckUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        return userData;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
// get Role approve by admin
Stream<QuerySnapshot> getUsersByRole(String role){
  return _firestore.collection('users').where('role', isEqualTo: role).snapshots();
}
   //approve user by id
   Future<void> approveUser(String userId)async{
    await _firestore.collection('users').doc(userId).update({
      'approved': true,
    });
   }
  // Delete or reject a user
  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }
}

final FirebaseService firebaseService = FirebaseService();



