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
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  String? _userTeamId;
  String? _userId;
  List<Map<String, dynamic>> _teams = [];

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  Future<void> _getUserInfo() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        _userId = user.uid;
        _userTeamId = userDoc.data()?['teamId'];
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchTeams() async {
    final teamsSnapshot = await FirebaseFirestore.instance.collection('teams').get();
    return teamsSnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> _joinTeam(String inviteCode) async {
    if (_userId != null) {
      setState(() {
        _isLoading = true;
      });
      final success = await _firestoreService.joinTeamWithInviteCode(userId: _userId!, inviteCode: inviteCode);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Joined team successfully!')),
        );
        await _getUserInfo();
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

  void _scrollToUserTeam(List<Map<String, dynamic>> teams) {
    if (_userTeamId != null) {
      final teamIndex = teams.indexWhere((team) => team['id'] == _userTeamId);
      if (teamIndex != -1) {
        _scrollController.animateTo(
          teamIndex * 200.0,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _showCreateTeamDialog() {
    String? teamName, abbreviation, location, description;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create Team'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Team Name'),
                  onChanged: (value) => teamName = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Abbreviation'),
                  onChanged: (value) => abbreviation = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Based in'),
                  onChanged: (value) => location = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Description'),
                  onChanged: (value) => description = value,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Create'),
              onPressed: () async {
                if (teamName != null && abbreviation != null && location != null && _userId != null) {
                  final teamId = await _firestoreService.createTeam(
                    name: teamName!,
                    captainId: _userId!,
                    abbreviation: abbreviation!,
                    location: location!,
                  );
                  if (teamId != null) {
                    await _firestoreService.updateUserTeam(_userId!, teamId);
                    await _getUserInfo();
                    Navigator.of(context).pop();
                    setState(() {});
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to create team')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showJoinTeamDialog() {
    String? inviteCode;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Join Team'),
          content: TextField(
            decoration: InputDecoration(labelText: 'Enter Invite Code'),
            onChanged: (value) => inviteCode = value,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Join'),
              onPressed: () {
                if (inviteCode != null) {
                  _joinTeam(inviteCode!);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _leaveTeam() async {
    if (_userId != null && _userTeamId != null) {
      await _firestoreService.updateUserTeam(_userId!, null);
      await _getUserInfo();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (_userTeamId == null) ...[
                  ElevatedButton(
                    onPressed: _showCreateTeamDialog,
                    child: Text('Create Team'),
                  ),
                  ElevatedButton(
                    onPressed: _showJoinTeamDialog,
                    child: Text('Join Team'),
                  ),
                ] else
                  ElevatedButton(
                    onPressed: () => _scrollToUserTeam(_teams),
                    child: Text('My Team'),
                  ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchTeams(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting || _isLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error loading teams'));
                }

                _teams = snapshot.data ?? [];

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: _teams.length,
                  itemBuilder: (context, index) {
                    final team = _teams[index];
                    final teamId = team['id'];
                    final teamName = team['name'] ?? 'No Name';
                    final abbreviation = team['abbreviation'] ?? 'N/A';
                    final location = team['location'] ?? 'Unknown';
                    final captainId = team['captainId'];
                    final inviteCode = team['inviteCode'];

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: teamId == _userTeamId ? Colors.blue : Colors.green,
                          width: 2,
                        ),
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
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Text(
                              abbreviation,
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Team Captain: ${captainId == _userId ? 'You' : 'Another player'}',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Location: $location',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            if (_userTeamId == null)
                              ElevatedButton(
                                onPressed: () => _joinTeam(inviteCode),
                                child: Text('Join Team'),
                              ),
                            if (teamId == _userTeamId) ...[
                              Text(
                                'Your Team',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Invite Code: $inviteCode',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: _leaveTeam,
                                child: Text('Leave Team'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

