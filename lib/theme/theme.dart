//theme.dart
import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  // Light color scheme
  brightness: Brightness.light,
  primaryColor: Colors.green[500], // Slightly richer green
  scaffoldBackgroundColor: Colors.green[50], // Subtle green background
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.green[500], // Rich green for the app bar
    elevation: 0, // Minimalist flat app bar
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: Colors.green[400], // Richer button green
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(
      color: Colors.black87, // Default text color for body
    ),
    bodyMedium: TextStyle(
      color: Colors.black54, // Secondary text color
    ),
    titleLarge: TextStyle(
      color: Colors.black87, // Text style for titles
      fontWeight: FontWeight.bold,
    ),
  ),
);
