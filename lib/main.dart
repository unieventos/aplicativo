import 'package:flutter/material.dart';
import 'login.dart'; // importa a sua tela de login
import 'eventRegister.dart';
import 'UserRegister.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
<<<<<<< HEAD
      home: LoginScreen(), // define a tela inicial como a de login
=======
      home: CadastroUsuarioPage() // define a tela inicial como a de login
>>>>>>> b45c12d (Inline CSS and UserRegister)
    );
  }
}