import 'package:flutter/material.dart';
import '../auth/authpage.dart'; // Import your reusable AuthPage
import 'package:firebase_auth/firebase_auth.dart';

class SignupPage extends AuthPage {
  SignupPage() : super(title: "Sign Up");

  @override
  Widget buildForm(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Column(
      children: [
        TextField(
          controller: nameController,
          decoration: InputDecoration(labelText: "Name"),
        ),
        TextField(
          controller: emailController,
          decoration: InputDecoration(labelText: "Email"),
        ),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(labelText: "Password"),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            try {
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
                email: emailController.text.trim(),
                password: passwordController.text.trim(),
              );
              Navigator.pushReplacementNamed(context, '/home'); // Redirect to Home
            } catch (e) {
              print("Error: $e");
            }
          },
          child: Text("Sign Up"),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Have an account? "),
            TextButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
              child: Text("Log in"),
            ),
          ],
        ),
      ],
    );
  }
}
  