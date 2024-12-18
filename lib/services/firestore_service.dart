import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> createTeam({
    required String name,
    required String captainId,
    required String abbreviation,
    required String location,
  }) async {
    try {
      final inviteCode = generateUniqueCode();
      final teamRef = await _firestore.collection('teams').add({
        'name': name,
        'captainId': captainId,
        'abbreviation': abbreviation,
        'location': location,
        'inviteCode': inviteCode,
        'playerIds': [captainId],
        'wins': 0,
        'losses': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return teamRef.id;
    } catch (e) {
      return null;
    }
  }

  Future<bool> joinTeamWithInviteCode({
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

        await _firestore.collection('teams').doc(teamId).update({
          'playerIds': FieldValue.arrayUnion([userId]),
        });

        await updateUserTeam(userId, teamId);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateUserTeam(String userId, String? teamId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'teamId': teamId ?? '',
      });
    } catch (e) {
      throw Exception("Failed to update user's team ID");
    }
  }

  Future<void> leaveTeam(String userId, String teamId) async {
    try {
      final teamDoc = await _firestore.collection('teams').doc(teamId).get();
      final teamData = teamDoc.data() as Map<String, dynamic>;
      final playerIds = List<String>.from(teamData['playerIds']);
      
      playerIds.remove(userId);
      
      if (playerIds.isEmpty) {
        // If no players left, delete the team
        await _firestore.collection('teams').doc(teamId).delete();
      } else {
        // Update team with new player list
        await _firestore.collection('teams').doc(teamId).update({
          'playerIds': playerIds,
        });
        
        // If the leaving user was the captain, assign a new random captain
        if (teamData['captainId'] == userId) {
          final newCaptainId = playerIds[Random().nextInt(playerIds.length)];
          await _firestore.collection('teams').doc(teamId).update({
            'captainId': newCaptainId,
          });
        }
      }
      
      // Update user's team ID to null
      await updateUserTeam(userId, null);
    } catch (e) {
      throw Exception("Failed to leave team");
    }
  }

  Future<List<Map<String, dynamic>>> fetchTeamPlayers(String teamId) async {
    try {
      final teamDoc = await _firestore.collection('teams').doc(teamId).get();
      final teamData = teamDoc.data() as Map<String, dynamic>;
      final playerIds = List<String>.from(teamData['playerIds']);
      
      final playersData = await Future.wait(
        playerIds.map((playerId) => _firestore.collection('users').doc(playerId).get())
      );
      
      return playersData.map((playerDoc) {
        final data = playerDoc.data() as Map<String, dynamic>;
        data['id'] = playerDoc.id;
        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Fetches the top scorer based on the highest total goals
  Future<String?> fetchTopScorer(String teamId) async {
    try {
      final players = await fetchTeamPlayers(teamId);
      
      String? topScorer;
      int highestGoals = 0;

      for (var player in players) {
        final totalGoals = player['totalGoals'] ?? 0;

        if (totalGoals > highestGoals) {
          highestGoals = totalGoals;
          topScorer = player['name'];
        }
      }

      return topScorer ?? 'N/A'; // Return 'N/A' if no scorer found
    } catch (e) {
      return 'Error'; // In case of error, return 'Error'
    }
  }

  // Fetches the top assist player based on the highest total assists
  Future<String?> fetchTopAssists(String teamId) async {
    try {
      final players = await fetchTeamPlayers(teamId);
      
      String? topAssist;
      int highestAssists = 0;

      for (var player in players) {
        final totalAssists = player['totalAssists'] ?? 0;

        if (totalAssists > highestAssists) {
          highestAssists = totalAssists;
          topAssist = player['name'];
        }
      }

      return topAssist ?? 'N/A'; // Return 'N/A' if no assists found
    } catch (e) {
      return 'Error'; // In case of error, return 'Error'
    }
  }

  String generateUniqueCode() {
    return DateTime.now().millisecondsSinceEpoch.toString().substring(6);
  }
}
