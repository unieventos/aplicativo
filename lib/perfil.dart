

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'login.dart'; // importa a sua tela de login
import 'eventRegister.dart';
import 'register.dart';
import 'modifyUser.dart';
import 'search.dart';
import 'UserRegister.dart';
import 'perfil.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'login.dart'; // importa a sua tela de login
import 'eventRegister.dart';
import 'register.dart';
import 'modifyUser.dart';
import 'home.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'perfil.dart';

class PerfilPage extends StatefulWidget {
  @override
  _PerfilPageState createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final storage = FlutterSecureStorage();
  String nome = '';
  String sobrenome = '';
  String email = '';
  String curso = '';
  String role = '';
  final bool isAdmin = true; // Altere para false se quiser simular usuário comum
  int _selectedIndex = 3; // índice de Admin alterado para 2

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final storedNome = utf8.decode((await storage.read(key: 'nome'))?.codeUnits ?? []);
    final storedSobrenome = utf8.decode((await storage.read(key: 'sobrenome'))?.codeUnits ?? []);
    final storedEmail = utf8.decode((await storage.read(key: 'email'))?.codeUnits ?? []);
    final storedCurso = utf8.decode((await storage.read(key: 'cursoId'))?.codeUnits ?? []);
    final storedRole = utf8.decode((await storage.read(key: 'role'))?.codeUnits ?? []);

    setState(() {
      nome = storedNome;
      sobrenome = storedSobrenome;
      email = storedEmail;
      curso = storedCurso;
      role = storedRole;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil do Usuário'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.person),
                      title: Text('$nome $sobrenome', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: Text('Nome completo'),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.email),
                      title: Text(email, style: TextStyle(fontSize: 18)),
                      subtitle: Text('Email'),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.school),
                      title: Text(curso, style: TextStyle(fontSize: 18)),
                      subtitle: Text('Curso'),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.admin_panel_settings),
                      title: Text(role, style: TextStyle(fontSize: 18)),
                      subtitle: Text('Perfil'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () async {
                await storage.deleteAll();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: Icon(Icons.logout, color: Colors.white),
              label: Text('Logout', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            
          ],
        ),
      ),
       bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == _selectedIndex) return;

          if (index == 0) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EventosApp()));
          } else if (index == 1) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EVRegister()));
          } else if (index == 2) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CadastroUsuarioPage()));
          } else if (index == 3) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PerfilPage()));
          }

          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.feed,
              color: _selectedIndex == 0 ? Colors.black : Colors.grey,
              size: _selectedIndex == 0 ? 28 : 24,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add,
              color: _selectedIndex == 1 ? Colors.black : Colors.grey,
              size: _selectedIndex == 1 ? 28 : 24,
            ),
            label: '',
          ),
          if (isAdmin)
            BottomNavigationBarItem(
              icon: Icon(
                Icons.admin_panel_settings,
                color: _selectedIndex == 2 ? Colors.black : Colors.grey,
                size: _selectedIndex == 2 ? 28 : 24,
              ),
              label: '',
            ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: _selectedIndex == 3 ? Colors.black : Colors.grey,
              size: _selectedIndex == 3 ? 28 : 24,
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}