// home.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return user != null
        ? Scaffold(
            appBar: AppBar(title: Text('Home')),
            body: Center(child: Text('Welcome, ${user.email}!')),
          )
        : LoginPage(); // Redirect to Login if not signed in
  }
}
