import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tourism/SignupPage.dart';
import 'package:tourism/firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Posting Pet',
      home: SignUpScreen(), // Uncomment this line and provide your widget here
    );
  }
}


