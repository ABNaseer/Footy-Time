import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // TEAM METHODS
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

  // TOURNAMENT METHODS
  Future<String?> createTournament({
    required String name,
    required String hostId,
    required List<String> teamIds,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final tournamentRef = await _firestore.collection('tournaments').add({
        'name': name,
        'hostId': hostId,
        'teamIds': teamIds,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return tournamentRef.id;
    } catch (e) {
      return null;
    }
  }

  // MATCH METHODS
  Future<String?> createMatch({
    required String tournamentId,
    required String team1Id,
    required String team2Id,
    required DateTime matchDate,
  }) async {
    try {
      final matchRef = await _firestore.collection('matches').add({
        'tournamentId': tournamentId,
        'team1Id': team1Id,
        'team2Id': team2Id,
        'score': {'team1': 0, 'team2': 0},
        'matchDate': matchDate.toIso8601String(),
      });
      return matchRef.id;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateMatchScore({
    required String matchId,
    required int team1Score,
    required int team2Score,
  }) async {
    try {
      await _firestore.collection('matches').doc(matchId).update({
        'score': {'team1': team1Score, 'team2': team2Score},
      });
    } catch (e) {
      throw Exception("Failed to update match score");
    }
  }
}