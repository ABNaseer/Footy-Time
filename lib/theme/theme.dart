import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  // Define the default brightness and colors.
  brightness: Brightness.dark,
  primaryColor: Colors.green[800], // Dark Green color
  scaffoldBackgroundColor: Colors.green[900], // Darker background for the app
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.green[800], // Dark Green for the app bar
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: Colors.green[700], // Button color
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(
      color: Colors.white, // Default text color for body
    ),
    bodyMedium: TextStyle(
      color: Colors.white70, // Secondary text color
    ),
    titleLarge: TextStyle(
      color: Colors.white, // Text style for titles
      fontWeight: FontWeight.bold,
    ),
  ),
);
