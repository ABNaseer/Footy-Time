import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> createTeam({
    required String name,
    required String captainId,
    required String abbreviation,
    required String location,
  }) async {
    try {
      final teamRef = await _firestore.collection('teams').add({
        'name': name,
        'captainId': captainId,
        'abbreviation': abbreviation,
        'location': location,
        'wins': 0,
        'losses': 0,
        'inviteCode': _generateInviteCode(),
        'playerIds': [captainId],
      });

      return teamRef.id;
    } catch (e) {
      print('Error creating team: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchTeamPlayers(String teamId) async {
    try {
      final playersSnapshot = await _firestore
          .collection('users')
          .where('teamId', isEqualTo: teamId)
          .get();
      List<Map<String, dynamic>> players = [];
      for (var doc in playersSnapshot.docs) {
        players.add(doc.data());
      }
      return players;
    } catch (e) {
      print('Error fetching players: $e');
      return [];
    }
  }

  Future<String?> joinTeamWithInviteCode({
    required String userId,
    required String inviteCode,
  }) async {
    try {
      final teamQuery = await _firestore
          .collection('teams')
          .where('inviteCode', isEqualTo: inviteCode)
          .get();

      if (teamQuery.docs.isNotEmpty) {
        final teamId = teamQuery.docs.first.id;

        // Add player to team
        await _firestore.collection('teams').doc(teamId).update({
          'playerIds': FieldValue.arrayUnion([userId]),
        });

        // Update user’s team ID
        await _firestore.collection('users').doc(userId).update({
          'teamId': teamId,
        });

        return teamId;
      }
      return null;
    } catch (e) {
      print('Error joining team: $e');
      return null;
    }
  }

  Future<void> leaveTeam(String userId, String teamId) async {
    try {
      // Remove player from team
      await _firestore.collection('teams').doc(teamId).update({
        'playerIds': FieldValue.arrayRemove([userId]),
      });

      // Clear user's team ID
      await _firestore.collection('users').doc(userId).update({
        'teamId': null,
      });
    } catch (e) {
      print('Error leaving team: $e');
    }
  }

  String _generateInviteCode() {
    // Generate a random invite code
    return DateTime.now().millisecondsSinceEpoch.toString().substring(6, 12);
  }
}
