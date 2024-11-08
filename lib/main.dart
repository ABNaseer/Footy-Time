import 'package:flutter/material.dart';
import 'screens/auth/splash.dart';
import 'theme/theme.dart'; // Import the theme file

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Football App',
      theme: appTheme, // Apply the theme here
      home: SplashScreen(),
    );
  }
}
