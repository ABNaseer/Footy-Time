import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
    required String dateOfBirth,
    required String phone,
    String? primaryPosition,
    List<String>? roles,
  }) async {
    try {
      // Create user in Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store additional user info in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'dateOfBirth': dateOfBirth,
        'primaryPosition': primaryPosition,
        'roles': roles ?? ['Player'], // Default role is Player
        'phone': phone,
        'teamId': null, // Default value for no team
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential.user!.uid;
    } on FirebaseAuthException catch (e) {
      // Return specific error messages
      switch (e.code) {
        case 'email-already-in-use':
          return "Email already in use";
        case 'invalid-email':
          return "Invalid email format";
        case 'weak-password':
          return "Password is too weak";
        default:
          return "Authentication error";
      }
    } catch (e) {
      return "Unexpected error occurred";
    }
  }

  Future<Map<String, dynamic>?> fetchUserData(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('users').doc(userId).get();
      return snapshot.data();
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    String? primaryPosition,
  }) async {
    try {
      Map<String, dynamic> updates = {};
      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (primaryPosition != null) updates['primaryPosition'] = primaryPosition;

      await _firestore.collection('users').doc(userId).update(updates);
      return true;
    } catch (e) {
      return false;
    }
  }
}
