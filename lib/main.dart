import 'package:flutter/material.dart';
import 'package:mad/screens/splash.dart';
import 'package:mad/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth/firebase_options.dart';
import 'screens/signup.dart';
import 'screens/login.dart';
import 'screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Football App',
      theme: appTheme,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashScreen(),
        '/home': (context) => HomePage(),
        '/login': (context) => LoginPage(),
        // Modified the signup route to accept arguments
        '/signup': (context) {
          final email = ModalRoute.of(context)?.settings.arguments as String?;
          final password = ModalRoute.of(context)?.settings.arguments as String?;
          return SignupPage(email: email ?? '', password: password ?? '');
        },
      },
    );
  }
}
