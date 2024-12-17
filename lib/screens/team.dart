import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mad/services/firestore_service.dart';

class TeamPage extends StatefulWidget {
  @override
  _TeamPageState createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;

  // Fetches all teams from Firestore
  Future<List<Map<String, dynamic>>> _fetchTeams() async {
    final teamsSnapshot = await FirebaseFirestore.instance.collection('teams').get();
    return teamsSnapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> _joinTeam(String teamId) async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      setState(() {
        _isLoading = true;
      });
      final success = await _firestoreService.joinTeamWithInviteCode(userId: userId, inviteCode: teamId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Joined team successfully!')),
        );
        setState(() {});  // Refresh the page to update the teamId
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid invite code')),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchTeams(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || _isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading teams'));
        }

        final teams = snapshot.data ?? [];

        return Scaffold(
          appBar: AppBar(
            title: Text('Teams'),
          ),
          body: ListView.builder(
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final team = teams[index];
              final teamId = team['id'];
              final teamName = team['name'] ?? 'No Name';
              final abbreviation = team['abbreviation'] ?? 'N/A';
              final location = team['location'] ?? 'Unknown';
              final captainName = team['captainName'] ?? 'Unknown';

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.green, width: 2),
                ),
                margin: EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        teamName,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,  // Centered team name
                      ),
                      SizedBox(height: 8),
                      Text(
                        abbreviation,
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                        textAlign: TextAlign.center,  // Centered abbreviation
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Captain: $captainName',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Location: $location',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          _joinTeam(teamId);  // Function to join team
                        },
                        child: Text('Join Team'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
