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

  Future<Map<String, dynamic>?> fetchTeamDetails(String teamId) async {
    try {
      final teamDoc = await _firestore.collection('teams').doc(teamId).get();
      if (teamDoc.exists) {
        return teamDoc.data();
      }
      return null;
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

  Future<void> addPlayerToTeam(String teamId, String playerId) async {
    try {
      await _firestore.collection('teams').doc(teamId).update({
        'playerIds': FieldValue.arrayUnion([playerId]),
      });
    } catch (e) {
      throw Exception("Failed to add player to team");
    }
  }

  Future<List<Map<String, dynamic>>> fetchTeams() async {
    try {
      final teamSnapshot = await _firestore.collection('teams').get();
      return teamSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  String generateUniqueCode() {
    return DateTime.now().millisecondsSinceEpoch.toString().substring(6);
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

  Future<void> updateTeamRecord(String teamId, bool isWin) async {
    try {
      await _firestore.collection('teams').doc(teamId).update({
        isWin ? 'wins' : 'losses': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception("Failed to update team record");
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
}

