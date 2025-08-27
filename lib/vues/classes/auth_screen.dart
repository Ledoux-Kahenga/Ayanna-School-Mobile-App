import 'package:ayanna_school/vues/gestions%20frais/paiement_frais.dart';
import 'package:flutter/material.dart';
import '../../theme/ayanna_theme.dart';
import '../widgets/ayanna_widgets.dart';
import '../../models/models.dart';

class AuthScreen extends StatefulWidget {
  final bool navigateToClasses;
  final AnneeScolaire? anneeScolaire;
  const AuthScreen({
    this.navigateToClasses = false,
    this.anneeScolaire,
    super.key,
  });

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
 
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => PaiementDesFrais(),
            ),
          );
       
      } else {
        _error = 'Identifiants invalides';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AyannaColors.lightGrey,
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
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Nom d\'utilisateur',
                  labelStyle: const TextStyle(color: AyannaColors.darkGrey),
                  filled: true,
                  fillColor: AyannaColors.white,
                  prefixIcon: const Icon(
                    Icons.person,
                    color: AyannaColors.orange,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AyannaColors.orange),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AyannaColors.orange,
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AyannaColors.lightGrey,
                      width: 2,
                    ),
                  ),
                ),
                style: const TextStyle(color: AyannaColors.darkGrey),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  labelStyle: const TextStyle(color: AyannaColors.darkGrey),
                  filled: true,
                  fillColor: AyannaColors.white,
                  prefixIcon: const Icon(
                    Icons.lock,
                    color: AyannaColors.orange,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AyannaColors.orange),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AyannaColors.orange,
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AyannaColors.lightGrey,
                      width: 2,
                    ),
                  ),
                ),
                style: const TextStyle(color: AyannaColors.darkGrey),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.login, color: AyannaColors.white),
                  label: const Text('Se connecter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AyannaColors.orange,
                    foregroundColor: AyannaColors.white,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _loading ? null : _login,
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: CircularProgressIndicator(color: AyannaColors.orange),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
