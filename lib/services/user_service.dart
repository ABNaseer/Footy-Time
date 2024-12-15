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
    String? primaryPosition,
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
        'role': 'Player', // Default role
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
}