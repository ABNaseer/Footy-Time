import 'package:flutter/material.dart';
import '../auth/authpage.dart';
import 'signup.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends AuthPage {
  LoginPage() : super(title: "Login");

  @override
  Widget buildForm(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Column(
      children: [
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
              await FirebaseAuth.instance.signInWithEmailAndPassword(
                email: emailController.text.trim(),
                password: passwordController.text.trim(),
              );
              Navigator.pushReplacementNamed(context, '/home');
            } catch (e) {
              print("Error: $e");
            }
          },
          child: Text("Login"),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Don't have an account? "),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignupPage()),
              ),
              child: Text(
                "Sign up",
                style: TextStyle(color: Colors.purple), // Purple-colored text
              ),
            ),
          ],
        ),
      ],
    );
  }
}
