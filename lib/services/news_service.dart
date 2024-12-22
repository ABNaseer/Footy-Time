import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class NewsService {
  final String apiKey = '6bbb90f3f6b345fb8aedcb8982ca6b18';

  Future<List<dynamic>> fetchMatches() async {
    final now = DateTime.now();
    final yesterday = now.subtract(Duration(days: 1));
    final tomorrow = now.add(Duration(days: 1));

    final dateFormat = DateFormat("yyyy-MM-dd");
    final fromDate = dateFormat.format(yesterday);
    final toDate = dateFormat.format(tomorrow);

    final url = Uri.parse('https://api.football-data.org/v4/matches?dateFrom=$fromDate&dateTo=$toDate');
    
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
    if (status == 'IN_PLAY' || status == 'PAUSED') {
      return 'ONGOING';
    } else if (status == 'FINISHED' || status == 'COMPLETED') {
      return 'FINISHED';
    } else if (status == 'TIMED' || status == 'SCHEDULED') {
      return 'UPCOMING';
    } else {
      return status;
    }
  }

  Color getMatchStatusColor(String status) {
    switch (status) {
      case 'ONGOING':
        return Colors.blue;
      case 'FINISHED':
        return Colors.brown;
      case 'UPCOMING':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  List<dynamic> getOngoingMatches(List<dynamic> matches) {
    return matches.where((match) => 
      match['status'] == 'IN_PLAY' || match['status'] == 'PAUSED'
    ).toList();
  }

  List<dynamic> getUpcomingMatches(List<dynamic> matches) {
    return matches.where((match) => 
      match['status'] == 'TIMED' || match['status'] == 'SCHEDULED'
    ).toList();
  }

  List<dynamic> getFinishedMatches(List<dynamic> matches) {
    return matches.where((match) => 
      match['status'] == 'FINISHED' || match['status'] == 'COMPLETED'
    ).toList();
  }

  List<dynamic> filterMatchesByStatus(List<dynamic> matches, String filter) {
    switch (filter) {
      case 'Ongoing':
        return getOngoingMatches(matches);
      case 'Upcoming':
        return getUpcomingMatches(matches);
      case 'Finished':
        return getFinishedMatches(matches);
      case 'All':
      default:
        return matches;
    }
  }

  List<dynamic> filterMatchesWithin24Hours(List<dynamic> matches) {
    final now = DateTime.now();
    final yesterday = now.subtract(Duration(days: 1));
    final tomorrow = now.add(Duration(days: 1));

    return matches.where((match) {
      final matchDate = DateTime.parse(match['utcDate']).toLocal();
      return matchDate.isAfter(yesterday) && matchDate.isBefore(tomorrow);
    }).toList();
  }
}

