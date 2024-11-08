import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 50), // Adds some space from the top
          Text(
            'Footy Time',
            style: GoogleFonts.roboto(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20), // Space between text and image
          Image.asset(
            'assets/img1.png', // Ensure the path and name are correct
            width: 150, // Adjust as needed
            height: 150,
          ),
        ],
      ),
    );
  }
}
