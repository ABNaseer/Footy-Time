import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class NewsService {
  final String apiKey = '6bbb90f3f6b345fb8aedcb8982ca6b18'; // Your API Key

  Future<List<dynamic>> fetchMatches() async {
    final url = Uri.parse('https://api.football-data.org/v4/matches');
    
    try {
      final response = await http.get(
        url,
        headers: {'X-Auth-Token': apiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['matches'] ?? [];
      } else {
        throw Exception('Failed to load matches: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to load matches: $e');
    }
  }

  String formatDate(DateTime dateTime) {
    final localTime = dateTime.toLocal();
    final now = DateTime.now();
    final difference = localTime.difference(now);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Tomorrow';
    } else if (difference.inDays == -1) {
      return 'Yesterday';
    } else {
      return '${localTime.day}/${localTime.month}/${localTime.year}';
    }
  }

  String formatKickoffTime(DateTime dateTime) {
    final localTime = dateTime.toLocal();
    final timeFormat = DateFormat.jm();
    return 'Kickoff: ${timeFormat.format(localTime)}';
  }

  String getScore(dynamic score, String team) {
    if (score == null) {
      return 'N/A';
    }

    if (score['fullTime'] != null) {
      if (team == 'home') {
        return score['fullTime']['home'].toString();
      } else if (team == 'away') {
        return score['fullTime']['away'].toString();
      }
    }

    if (score['halfTime'] != null) {
      if (team == 'home') {
        return score['halfTime']['home'].toString();
      } else if (team == 'away') {
        return score['halfTime']['away'].toString();
      }
    }

    return 'N/A';
  }

  String getMatchStatus(String status) {
    if (status == 'IN_PLAY') {
      return 'IN PLAY';
    } else if (status == 'FINISHED') {
      return 'FINISHED';
    } else {
      return 'TIMED';
    }
  }

  Color getMatchStatusColor(String status) {
    if (status == 'IN_PLAY') {
      return Colors.blue;
    } else if (status == 'FINISHED') {
      return Colors.brown;
    } else {
      return Colors.green;
    }
  }

  List<dynamic> filterMatchesByStatus(List<dynamic> matches, String filter) {
    if (filter == 'All') {
      return matches;
    }

    // Handle filter by specific status
    return matches.where((match) {
      final status = getMatchStatus(match['status']);
      if (filter == 'Ongoing') {
        return status == 'IN_PLAY';  // Ongoing matches
      } else if (filter == 'Upcoming') {
        return status == 'SCHEDULED';  // Scheduled but not started matches
      } else if (filter == 'Finished') {
        return status == 'FINISHED';  // Completed matches
      }
      return false;  // Default case (should not hit this if filter is valid)
    }).toList();
  }

  void sortMatchesByCompetition(List<dynamic> matches) {
    matches.sort((a, b) => a['competition']['name'].compareTo(b['competition']['name']));
  }
}
