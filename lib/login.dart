import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


import 'package:flutter_application_1/home.dart';
import 'package:flutter_application_1/auth_service.dart';
import 'package:flutter_application_1/user_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _storage = FlutterSecureStorage();

  bool _permanecerLogado = false;
  bool _isLoading = false;
  bool _obscureText = true;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();
    
    try {
      final token = await AuthService.fazerLogin(
        _emailController.text.trim(),
        _senhaController.text.trim(),
        _permanecerLogado,
      );

      if (token != null && mounted) {
        await _storage.write(key: 'token', value: token);
        await _storage.write(key: 'permanecerLogado', value: _permanecerLogado.toString());
        // O role será definido pelo UserService.buscarUsuario() após login
        
        await UserService.buscarUsuario();
        
        // Navega para a sua tela principal, EventosPage
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => EventosPage()));
      } else {
        _showErrorSnackBar('Login ou Senha inválidos');
      }
    } catch (e) {
      _showErrorSnackBar('Ocorreu um erro. Tente novamente.');
      print('Erro no login: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFFCC2229),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      // Usamos um LayoutBuilder para ter certeza do espaço disponível
      // e um SingleChildScrollView para o caso de telas menores.
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // --- SEU HEADER ORIGINAL ---
                    // Mantido exatamente como você projetou.
                    Container(
                      height: size.height * 0.30,
                      width: double.infinity,
                      decoration: BoxDecoration(color: Color(0xFFCC2229)),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          widthFactor: 0.6, // Ajuste o tamanho do logo aqui
                          child: Image.asset('assets/logo.png', fit: BoxFit.contain),
                        ),
                      ),
                    ),

                    // --- FORMULÁRIO ---
                    // Adicionado um Spacer para empurrar o formulário para baixo e centralizá-lo verticalmente.
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: _buildInputDecoration(label: "Nome de Usuário (login)", icon: Icons.person_outline),
                              validator: (value) => (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _senhaController,
                              obscureText: _obscureText,
                              decoration: _buildInputDecoration(label: "Senha", icon: Icons.lock_outline).copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                                  onPressed: () => setState(() => _obscureText = !_obscureText),
                                ),
                              ),
                              validator: (value) => (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Checkbox(
                                  value: _permanecerLogado,
                                  onChanged: (value) => setState(() => _permanecerLogado = value ?? false),
                                  activeColor: Color(0xFFCC2229),
                                ),
                                Text("Permanecer logado"),
                              ],
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _loginUser,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF6D4C41), // Sua cor marrom
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                minimumSize: Size(double.infinity, 50),
                                elevation: 5,
                              ),
                              child: _isLoading
                                  ? CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                                  : Text(
                                      "LOGIN",
                                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Spacer(), // Adicionado outro Spacer para equilíbrio
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper para criar a decoração dos TextFields
  InputDecoration _buildInputDecoration({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey[600]),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Color(0xFFCC2229), width: 2),
      ),
    );
  }
}
