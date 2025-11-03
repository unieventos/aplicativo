import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter_application_1/auth_service.dart';
import 'package:flutter_application_1/home.dart';
import 'package:flutter_application_1/user_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

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
        await _storage.write(
          key: 'permanecerLogado',
          value: _permanecerLogado.toString(),
        );
        // O role será definido pelo UserService.buscarUsuario() após login

        await UserService.buscarUsuario();

        // Navega para a sua tela principal, EventosPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const EventosPage()),
        );
      } else {
        _showErrorSnackBar('Login ou Senha inválidos');
      }
    } catch (e) {
      _showErrorSnackBar('Ocorreu um erro. Tente novamente.');
      debugPrint('Erro no login: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _LoginHeader(isLoading: _isLoading),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 28,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Seja bem-vindo',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Use suas credenciais institucionais para acessar a plataforma.',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 24),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  decoration: _buildInputDecoration(
                                    label: 'Nome de usuário (login)',
                                    icon: Icons.person_outline,
                                  ),
                                  validator: (value) =>
                                      (value == null || value.isEmpty)
                                      ? 'Campo obrigatório'
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _senhaController,
                                  obscureText: _obscureText,
                                  decoration:
                                      _buildInputDecoration(
                                        label: 'Senha',
                                        icon: Icons.lock_outline,
                                      ).copyWith(
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscureText
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                          ),
                                          onPressed: () => setState(
                                            () => _obscureText = !_obscureText,
                                          ),
                                        ),
                                      ),
                                  validator: (value) =>
                                      (value == null || value.isEmpty)
                                      ? 'Campo obrigatório'
                                      : null,
                                ),
                                const SizedBox(height: 12),
                                CheckboxListTile(
                                  value: _permanecerLogado,
                                  contentPadding: EdgeInsets.zero,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  title: const Text('Permanecer conectado'),
                                  onChanged: (value) => setState(
                                    () => _permanecerLogado = value ?? false,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: _isLoading ? null : _loginUser,
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : const Text('Entrar'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(labelText: label, prefixIcon: Icon(icon));
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader({required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFCC2229), Color(0xFFB51E24)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isLoading)
            Align(
              alignment: Alignment.topRight,
              child: Image.asset(
                'assets/logo.png',
                height: 64,
                fit: BoxFit.contain,
              ),
            ),
          const SizedBox(height: 32),
          Text(
            'Eventos UNISAGRADO',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Conecte-se aos próximos eventos, inscrições e conteúdos exclusivos.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
