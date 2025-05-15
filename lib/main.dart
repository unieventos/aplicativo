import 'package:flutter/material.dart';
import 'package:flutter_application_1/search.dart';
import 'login.dart'; // importa a sua tela de login
import 'eventRegister.dart';
import 'UserRegister.dart';
import 'register.dart';
import 'modifyUser.dart';
import 'home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CadastroUsuarioPage() // define a tela inicial como a de login
    );
  }
}