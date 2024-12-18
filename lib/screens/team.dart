import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mad/services/firestore_service.dart';
import 'package:mad/services/user_service.dart';

class TeamPage extends StatefulWidget {
  @override
  _TeamPageState createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final UserService _userService = UserService();

  String? _userId;
  String? _userTeamId;
  bool _isLoading = true;
  List<Map<String, dynamic>> _teams = [];
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        _userId = user.uid;
        _userTeamId = userDoc['teamId'];
      });
      _fetchTeams();
    }
  }

  Future<void> _fetchTeams() async {
    final teamsSnapshot = await FirebaseFirestore.instance.collection('teams').get();
    List<Map<String, dynamic>> teams = [];
    for (var doc in teamsSnapshot.docs) {
      final data = doc.data();
      data['id'] = doc.id;

      // Get the captain name
      final captainData = await _userService.fetchPublicUserProfile(data['captainId']);
      data['captainName'] = captainData?['name'] ?? 'Unknown';

      // Get top scorer and top assist
      final players = await _firestoreService.fetchTeamPlayers(data['id']);
      String topScorer = 'N/A';
      String topAssists = 'N/A';
      
      // Find the top scorer and top assist player
      if (players.isNotEmpty) {
        var topScorerPlayer = players.reduce((a, b) => a['goals'] > b['goals'] ? a : b);
        var topAssistsPlayer = players.reduce((a, b) => a['assists'] > b['assists'] ? a : b);
        
        topScorer = topScorerPlayer['name'];
        topAssists = topAssistsPlayer['name'];
      }

      data['topScorer'] = topScorer;
      data['topAssists'] = topAssists;

      teams.add(data);
    }
    setState(() {
      _teams = teams;
      _isLoading = false;
    });
  }

  void _showTeamDetails(Map<String, dynamic> team) async {
    final players = await _firestoreService.fetchTeamPlayers(team['id']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(team['name']),
        content: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Location: ${team['location']}"),
              Text("Wins: ${team['wins']}, Losses: ${team['losses']}"),
              Text("Top Scorer: ${team['topScorer']}"),
              Text("Top Assists: ${team['topAssists']}"),
              Divider(),
              ...players.map((player) {
                final isUser = player['id'] == _userId;
                return ListTile(
                  title: Text(
                    player['name'],
                    style: TextStyle(color: isUser ? Colors.orange : Colors.black),
                  ),
                  subtitle: Text(player['primaryPosition'] ?? 'Unknown'),
                  trailing: isUser ? Text("(You)") : null,
                );
              }).toList(),
              if (team['captainId'] == _userId)
                Column(
                  children: [
                    Divider(),
                    Text("Invite Code: ${team['inviteCode']}"),
                  ],
                ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Close')),
        ],
      ),
    );
  }

  void _showCreateTeamDialog() {
    final _formKey = GlobalKey<FormState>();
    String name = '';
    String abbreviation = '';
    String location = '';
    String description = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create Team'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Team Name'),
                onSaved: (value) => name = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Abbreviation'),
                onSaved: (value) => abbreviation = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Location'),
                onSaved: (value) => location = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                onSaved: (value) => description = value!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              _formKey.currentState?.save();
              if (_userId != null) {
                final teamId = await _firestoreService.createTeam(
                  name: name,
                  captainId: _userId!,
                  abbreviation: abbreviation,
                  location: location,
                );
                // Update the user's team ID
                await FirebaseFirestore.instance.collection('users').doc(_userId).update({
                  'teamId': teamId,
                });
                _fetchUserInfo(); // Refresh user info and teams after creation
              }
              Navigator.pop(context);
            },
            child: Text('Create'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showJoinTeamDialog() {
    String inviteCode = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Join Team'),
        content: TextFormField(
          decoration: InputDecoration(labelText: 'Invite Code'),
          onChanged: (value) => inviteCode = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_userId != null) {
                // Call the join team method with the invite code
                final teamId = await _firestoreService.joinTeamWithInviteCode(
                  userId: _userId!,
                  inviteCode: inviteCode,
                );
                
                // Check if a valid teamId was returned
                if (teamId != null) {
                  // Update the user's teamId to the correct teamId
                  await FirebaseFirestore.instance.collection('users').doc(_userId).update({
                    'teamId': teamId,
                  });
                  
                  // Fetch the updated user info
                  _fetchUserInfo(); // Refresh user info after joining
                } else {
                  // Handle invalid invite code
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Invalid invite code')),
                  );
                }
              }
              Navigator.pop(context); // Close the dialog
            },
            child: Text('Join'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _leaveTeam() async {
    if (_userId != null && _userTeamId != null) {
      // Remove player from the team
      await _firestoreService.leaveTeam(_userId!, _userTeamId!);

      // Clear the user's teamId
      await FirebaseFirestore.instance.collection('users').doc(_userId).update({
        'teamId': null,
      });

      _fetchUserInfo(); // Refresh user info after leaving the team
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_userTeamId != null && _userTeamId!.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      final team = _teams.firstWhere((team) => team['id'] == _userTeamId);
                      final index = _teams.indexOf(team);
                      _scrollController.animateTo(
                        index * 120.0,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Text('My Team'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _leaveTeam,
                    child: Text('Leave Team'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            if (_userTeamId == null || _userTeamId!.isEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _showCreateTeamDialog,
                    child: Text('Create Team'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _showJoinTeamDialog,
                    child: Text('Join Team'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: _teams.length,
                      itemBuilder: (context, index) {
                        final team = _teams[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.green, width: 2),
                          ),
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: InkWell(
                            onTap: () => _showTeamDetails(team),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    team['name'],
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  Text('Location: ${team['location']}'),
                                  Text('Wins: ${team['wins']}, Losses: ${team['losses']}'),
                                  Text('Captain: ${team['captainName']}'),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
