import 'package:flutter/material.dart';
import 'login.dart'; // importa a sua tela de login
import 'eventRegister.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(), // define a tela inicial como a de login
    );
  }
}