// home.dart
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile.dart'; // Import your profile page
import 'team.dart'; // Import your team page
import 'tournament.dart'; // Import your tournament page
import 'shop.dart'; // Import your shop page
import 'login.dart'; // Import login page

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Track the current selected screen index

  // List of screens to be displayed
  final List<Widget> _screens = [
    MyProfilePage(), // Default screen
    TeamPage(),
    TournamentPage(),
    ShopPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return user != null
        ? Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.green[700],
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sports_soccer, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Footy Time',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            body: _screens[_selectedIndex], // Display the selected screen
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              backgroundColor: Colors.green[800],
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.grey,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'My Profile',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.group),
                  label: 'My Team',
                ),
                BottomNavigationBarItem(
                  icon: Icon(FontAwesomeIcons.trophy),
                  label: 'Tournament',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.store),
                  label: 'Shop',
                ),
              ],
              onTap: _onItemTapped, // Handle the navigation tap
            ),
          )
        : LoginPage(); // Redirect to Login if not signed in
  }
}
