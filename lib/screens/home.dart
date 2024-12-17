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

  // Logout method
  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Optionally, navigate to the login screen after logging out
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error logging out")));
    }
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
              actions: [
                IconButton(
                  icon: Icon(Icons.exit_to_app, color: Colors.white), // Set icon color to white
                  onPressed: _logout, // Call logout method when tapped
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    'Logout', 
                    style: TextStyle(color: Colors.white), // Set text color to white
                  ),
                ),
              ],
            ),
            body: _screens[_selectedIndex], // Display the selected screen
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              backgroundColor: Colors.green[800],
              selectedItemColor: Colors.green[400], // Highlight selected item with a lighter green
              unselectedItemColor: Colors.black, // Unselected items in a lighter shade of green
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
