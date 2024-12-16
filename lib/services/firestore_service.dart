//firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // TEAM METHODS
  Future<String?> createTeam({
    required String name,
    required String captainId,
    required List<String> playerIds,
  }) async {
    try {
      final teamRef = await _firestore.collection('teams').add({
        'name': name,
        'captainId': captainId,
        'playerIds': playerIds,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return teamRef.id;
    } catch (e) {
      return null;
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
        'score': {'team1': 0, 'team2': 0}, // Default score
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
