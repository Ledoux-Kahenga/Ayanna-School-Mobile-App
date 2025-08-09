import 'package:flutter/material.dart';
import '../widgets/ayanna_widgets.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  void _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    // TODO: Authentification réelle avec la base de données
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _loading = false;
      if (_usernameController.text == 'admin' &&
          _passwordController.text == 'admin') {
        // Naviguer vers la page suivante
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        _error = 'Identifiants invalides';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AyannaLogo(size: 120),
              const SizedBox(height: 24),
              Text('Connexion', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              AyannaTextField(
                label: 'Nom d’utilisateur',
                controller: _usernameController,
              ),
              AyannaTextField(
                label: 'Mot de passe',
                controller: _passwordController,
                obscureText: true,
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              _loading
                  ? const CircularProgressIndicator()
                  : AyannaButton(text: 'Se connecter', onPressed: _login),
            ],
          ),
        ),
      ),
    );
  }
}
