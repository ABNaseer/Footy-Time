import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context)
          .scaffoldBackgroundColor, // Use dark green as background
      body: Center(
        child: Container(
          color: Theme.of(context)
              .scaffoldBackgroundColor, // Same color for the whole screen
        ),
      ),
    );
  }
}
