import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<dynamic> _matches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMatches();
  }

  Future<void> _fetchMatches() async {
    final url = Uri.parse('https://api.football-data.org/v4/matches');
    final apiKey = '6bbb90f3f6b345fb8aedcb8982ca6b18'; // Your API Key

    try {
      final response = await http.get(
        url,
        headers: {'X-Auth-Token': apiKey}, // Send API key in header
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _matches = data['matches'] ?? [];
          _matches.sort((a, b) => DateTime.parse(b['utcDate']).compareTo(DateTime.parse(a['utcDate']))); // Sort matches from latest to oldest
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load matches: ${response.reasonPhrase}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load matches: ${e.toString()}')),
      );
    }
  }

  // Format the date as Today, Yesterday, Tomorrow
  String _formatDate(DateTime dateTime) {
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

  // Format time in local AM/PM format
  String _formatTime(DateTime dateTime) {
    final localTime = dateTime.toLocal();
    final timeFormat = DateFormat.jm(); // This will give AM/PM format
    return timeFormat.format(localTime);
  }

  // Safe way to get score data
  String _getScore(dynamic score, String team) {
    if (score == null) {
      return 'N/A'; // For future matches
    }

    // Check for fullTime score (finished match)
    if (score['fullTime'] != null) {
      if (team == 'home') {
        return score['fullTime']['home'].toString(); // Home team full-time score
      } else if (team == 'away') {
        return score['fullTime']['away'].toString(); // Away team full-time score
      }
    }

    // If the match is ongoing (IN_PLAY), check for half-time score
    if (score['halfTime'] != null) {
      if (team == 'home') {
        return score['halfTime']['home'].toString(); // Home team half-time score
      } else if (team == 'away') {
        return score['halfTime']['away'].toString(); // Away team half-time score
      }
    }

    // If neither fullTime nor halfTime, return 'N/A'
    return 'N/A';
  }

  // Determine match status display
  String _getMatchStatus(String status) {
    if (status == 'IN_PLAY') {
      return 'IN PLAY';
    } else if (status == 'FINISHED') {
      return 'FINISHED';
    } else {
      return 'TIMED'; // For upcoming matches
    }
  }

  // Determine the background color for each match status
  Color _getMatchStatusColor(String status) {
    if (status == 'IN_PLAY') {
      return Colors.blue; // IN PLAY matches will be blue
    } else if (status == 'FINISHED') {
      return Colors.brown; // FINISHED matches will be brown
    } else {
      return Colors.green; // TIMED matches (future) will be green
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Football Matches'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchMatches,
              child: _matches.isEmpty
                  ? Center(
                      child: Text(
                        'No matches available',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _matches.length,
                      itemBuilder: (context, index) {
                        final match = _matches[index];
                        final matchDate = DateTime.parse(match['utcDate']);
                        final leagueName = match['competition']['name'] ?? 'Unknown League';
                        final status = match['status'] ?? 'TIMED'; // Default to TIMED if no status

                        final homeTeamName = match['homeTeam']['name'] ?? 'Unknown Team';
                        final awayTeamName = match['awayTeam']['name'] ?? 'Unknown Team';

                        final homeScore = _getScore(match['score'], 'home');
                        final awayScore = _getScore(match['score'], 'away');

                        return Card(
                          margin: EdgeInsets.all(8),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          color: _getMatchStatusColor(status), // Set background color based on status
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Centered League Name
                                Center(
                                  child: Text(
                                    leagueName,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12),
                                // Match Date and Time
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatDate(matchDate),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      _formatTime(matchDate),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                // Teams and Score
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        homeTeamName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8),
                                      child: Text(
                                        'vs.',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        awayTeamName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                // Display Score
                                Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '$homeScore - $awayScore',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Match Status
                                SizedBox(height: 8),
                                Text(
                                  'Status: ${_getMatchStatus(status)}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
