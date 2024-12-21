import 'package:flutter/material.dart';
import '../services/news_service.dart'; // Import the NewsService
import 'package:intl/intl.dart';

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<dynamic> _matches = [];
  bool _isLoading = true;
  String _filter = 'All'; // Filter for match status
  final NewsService _newsService = NewsService();

  @override
  void initState() {
    super.initState();
    _fetchMatches();
  }

  Future<void> _fetchMatches() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final matches = await _newsService.fetchMatches();
      setState(() {
        _matches = matches;
        _matches.sort((a, b) => DateTime.parse(b['utcDate']).compareTo(DateTime.parse(a['utcDate']))); // Sort matches from latest to oldest
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load matches: ${e.toString()}')),
      );
    }
  }

  void _applyFilter(String filter) {
    setState(() {
      _filter = filter;
      if (filter == 'All') {
        _fetchMatches();
      } else {
        _matches = _newsService.filterMatchesByStatus(_matches, filter);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null, // Removed the AppBar
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'News',
              style: TextStyle(
                color: Colors.green,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  _applyFilter('Ongoing');
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: Text(
                  'Ongoing',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  _applyFilter('Upcoming');
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text(
                  'Upcoming',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  _applyFilter('Finished');
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
                child: Text(
                  'Finished',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  _applyFilter('All');
                },
                child: Text(
                  'All Matches',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
          Expanded(
            child: _isLoading
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
                              final status = match['status'] ?? 'TIMED';
                              final homeTeamName = match['homeTeam']['name'] ?? 'Unknown Team';
                              final awayTeamName = match['awayTeam']['name'] ?? 'Unknown Team';
                              final homeScore = _newsService.getScore(match['score'], 'home');
                              final awayScore = _newsService.getScore(match['score'], 'away');
                              final homeTeamCrest = match['homeTeam']['crest'] ?? ''; // Team crest URL
                              final awayTeamCrest = match['awayTeam']['crest'] ?? ''; // Team crest URL
                              final leagueLogo = match['competition']['emblem'] ?? ''; // League logo URL

                              return Card(
                                margin: EdgeInsets.all(8),
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                color: _newsService.getMatchStatusColor(status),
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: leagueLogo.isNotEmpty
                                            ? Image.network(
                                                leagueLogo,
                                                width: 40,
                                                height: 40,
                                                fit: BoxFit.contain,
                                              )
                                            : SizedBox(),
                                      ),
                                      SizedBox(height: 12),
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
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _newsService.formatDate(matchDate),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            _newsService.formatKickoffTime(matchDate),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            backgroundImage: NetworkImage(homeTeamCrest),
                                            radius: 20,
                                          ),
                                          SizedBox(width: 8),
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
                                          CircleAvatar(
                                            backgroundImage: NetworkImage(awayTeamCrest),
                                            radius: 20,
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
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
                                      SizedBox(height: 8),
                                      Text(
                                        'Status: ${_newsService.getMatchStatus(status)}',
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
          ),
        ],
      ),
    );
  }
}
