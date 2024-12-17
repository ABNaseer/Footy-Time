// user_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up a new user
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
    required String dateOfBirth,
    required String phone,
    String? primaryPosition,
    List<String>? roles,
    String? profilePicture, // Add profile picture URL
  }) async {
    try {
      // Create user in Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store additional user info in Firestore, including profilePicture and default stats as 0
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'dateOfBirth': dateOfBirth,
        'primaryPosition': primaryPosition,
        'roles': roles ?? ['Player'], // Default role is Player
        'phone': phone,
        'teamId': null, // Default value for no team
        'profilePicture': profilePicture ?? '', // Save profile picture URL if provided
        'goals': 0,  // Set goals to 0
        'assists': 0, // Set assists to 0
        'yellowCards': 0, // Set yellow cards to 0
        'redCards': 0, // Set red cards to 0
        'matchMVP': 0, // Set Match MVP count to 0
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

  // Fetch user data including stats like MVP, Goals, Assists, Yellow Cards, Red Cards
  Future<Map<String, dynamic>?> fetchUserData(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('users').doc(userId).get();
      return snapshot.data();
    } catch (e) {
      return null;
    }
  }

  // Update user profile (including profile picture)
  Future<bool> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    String? primaryPosition,
    String? profilePicture, // Add profile picture URL
  }) async {
    try {
      Map<String, dynamic> updates = {};
      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (primaryPosition != null) updates['primaryPosition'] = primaryPosition;
      if (profilePicture != null) updates['profilePicture'] = profilePicture;

      await _firestore.collection('users').doc(userId).update(updates);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Upload image to ImgBB
  Future<String?> uploadImageToImgBB(String imagePath) async {
    String apiKey = 'd89ed759885ce6ed128b5eeb1257c677';
    String url = 'https://api.imgbb.com/1/upload';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields['key'] = apiKey;
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));

      var response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final result = jsonDecode(responseData);
        return result['data']['url']; // Return the image URL
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // New method: Fetch a user’s public profile
  Future<Map<String, dynamic>?> fetchPublicUserProfile(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('users').doc(userId).get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data()!;
        // Return only selected fields for public profile
        return {
          'name': data['name'],
          'primaryPosition': data['primaryPosition'],
          'profilePicture': data['profilePicture'],
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update user stats (Goals, Assists, Yellow Cards, Red Cards)
  Future<bool> updateUserStats({
    required String userId,
    int? goals,
    int? assists,
    int? yellowCards,
    int? redCards,
    int? matchMVP, // Add Match MVP stat
  }) async {
    try {
      Map<String, dynamic> updates = {};
      updates['goals'] = goals ?? 0; // Set goals to 0 if not provided
      updates['assists'] = assists ?? 0; // Set assists to 0 if not provided
      updates['yellowCards'] = yellowCards ?? 0; // Set yellow cards to 0 if not provided
      updates['redCards'] = redCards ?? 0; // Set red cards to 0 if not provided
      updates['matchMVP'] = matchMVP ?? 0; // Set Match MVP to 0 if not provided

      await _firestore.collection('users').doc(userId).update(updates);
      return true;
    } catch (e) {
      return false;
    }
  }
}
