// profile.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyProfilePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> _fetchUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      return userDoc.data() ?? {};
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading data'));
        }

        final userData = snapshot.data ?? {};

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Profile',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.green,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              SizedBox(height: 16),
              Text('Name: ${userData['name'] ?? 'N/A'}'),
              Text('Email: ${userData['email'] ?? 'N/A'}'),
              Text('Date of Birth: ${userData['dateOfBirth'] ?? 'N/A'}'),
              Text('Primary Position: ${userData['primaryPosition'] ?? 'N/A'}'),
              Text('Phone: ${userData['phone'] ?? 'N/A'}'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // You can add functionality to edit profile
                },
                child: Text('Edit Profile'),
              ),
            ],
          ),
        );
      },
    );
  }
}
