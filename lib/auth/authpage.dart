
import 'package:flutter/material.dart';

abstract class AuthPage extends StatelessWidget {
  final String title;

  AuthPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(child: buildForm(context)),
      ),
    );
  }

  Widget buildForm(BuildContext context);
}
