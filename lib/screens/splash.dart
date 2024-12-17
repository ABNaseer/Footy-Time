import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Add this package for SVG support

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get screen size for relative positioning
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        // Navigate to the home page or the desired page after the splash
        Navigator.pushReplacementNamed(context, '/home'); // Change '/home' to '/login' or '/signup' as per your flow
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            // Centered football icon
            Center(
              child: SvgPicture.asset(
                'assets/football_icon2.svg', // Use an SVG football icon for scalability
                width: size.width * 0.4, // 40% of screen width
              ),
            ),
            // Footer text
            Positioned(
              bottom: size.height * 0.05, // 5% from the bottom
              width: size.width, // Full width
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Footy Time by Abdullah Naseer',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'FA22-BSE-018',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
