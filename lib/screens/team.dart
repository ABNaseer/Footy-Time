// team.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeamPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> _fetchTeamData() async {
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
      future: _fetchTeamData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading data'));
        }

        final userData = snapshot.data ?? {};
        final teamId = userData['teamId'];

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Team',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              teamId != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Team: $teamId'),
                        ElevatedButton(
                          onPressed: () {
                            // You can add functionality to leave the team
                          },
                          child: Text('Leave Team'),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Text('You are not part of a team.'),
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to create or join a team
                          },
                          child: Text('Join/Create Team'),
                        ),
                      ],
                    ),
            ],
          ),
        );
      },
    );
  }
}
