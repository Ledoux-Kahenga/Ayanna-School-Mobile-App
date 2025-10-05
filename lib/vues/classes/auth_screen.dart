import 'dart:math' as math;
import 'package:ayanna_school/models/entities/annee_scolaire.dart';
import 'package:ayanna_school/models/entities/utilisateur.dart';
import 'package:ayanna_school/vues/gestions%20frais/paiement_frais.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/providers/providers.dart';

import '../../theme/ayanna_theme.dart';
import '../widgets/ayanna_widgets.dart';


class AuthScreen extends ConsumerStatefulWidget {
  final bool navigateToClasses;
  final AnneeScolaire? anneeScolaire;
  const AuthScreen({
    this.navigateToClasses = false,
    this.anneeScolaire,
    super.key,
  });

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController(
    text: 'admin@collegeleparadoxe.com',
  );
  final _passwordController = TextEditingController(text: '123456');
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _errorMessage;

  /// Vérifie si la base de données locale est vide
  Future<bool> _isDatabaseEmpty() async {
    print('=== VÉRIFICATION BASE DE DONNÉES LOCALE ===');
    try {
      final db = ref.watch(databaseProvider);
      final entreprises = await db.entrepriseDao.getAllEntreprises();
      final utilisateurs = await db.utilisateurDao.getAllUtilisateurs();
      final anneesScol = await db.anneeScolaireDao.getAllAnneesScolaires();

      bool isEmpty =
          entreprises.isEmpty && utilisateurs.isEmpty && anneesScol.isEmpty;

      print('📊 Entreprises trouvées: ${entreprises.length}');
      print('📊 Utilisateurs trouvés: ${utilisateurs.length}');
      print('📊 Années scolaires trouvées: ${anneesScol.length}');
      print(
        isEmpty ? '📊 Base de données VIDE' : '📊 Base de données NON VIDE',
      );

      return isEmpty;
    } catch (e) {
      print('❌ Erreur lors de la vérification BD: $e');
      rethrow; // Considérer comme vide en cas d'erreur
    }
  }

  /// Vérifie l'authentification dans la base locale
  
  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez saisir votre email';
      });
      return;
    }

    if (_passwordController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez saisir votre mot de passe';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      print('=== DÉBUT PROCESSUS DE CONNEXION ===');
      print('Email: $email');
      final shpref=await ref.read(syncPreferencesNotifierProvider.notifier);
     // shpref.clearSyncData();
      final loginSuccess = await ref.watch(authNotifierProvider.notifier).login(email, password);
      
      if (loginSuccess) {
        print('✅ Connexion réussie');

        // Naviguer vers l'écran principal
        if (widget.navigateToClasses && widget.anneeScolaire != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaiementDesFrais(
                anneeScolaire: widget.anneeScolaire,
              ),
            ),
          );
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        print('❌ Échec de la connexion');
        setState(() {
          _errorMessage = 'Échec de la connexion. Veuillez réessayer.';
        });
      }

    } catch (e, stackTrace) {
      print('❌ ERREUR GÉNÉRALE LOGIN: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _errorMessage = 'Erreur de connexion: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Fonction pour récupérer les infos utilisateur depuis le serveur (développement)
  Future<void> _fetchUserInfo() async {
    print('=== DEBUG _fetchUserInfo appelée ===');

    if (_emailController.text.trim().isEmpty) {
      print('Email vide, affichage erreur');
      setState(() {
        _errorMessage = 'Veuillez saisir un email pour récupérer les infos';
      });
      return;
    }

    print('Email fourni: ${_emailController.text.trim()}');
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: Implémenter la récupération d'informations utilisateur
      print('Fonctionnalité getUserFromServer temporairement désactivée');

      // Pour l'instant, afficher un message informatif
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Information'),
            content: Text(
              'La fonctionnalité de récupération des informations utilisateur sera implémentée prochainement.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e, stackTrace) {
      print('ERREUR dans _fetchUserInfo: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _errorMessage = 'Erreur lors de la récupération: $e';
      });
    } finally {
      print('Fin _fetchUserInfo, arrêt du loading');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Debug: Vider la base de données locale
  Future<void> _clearLocalDatabase() async {
    print('=== DEBUG: VIDAGE BASE DE DONNÉES ===');

    if (!mounted) return;

    // Confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmer le vidage'),
        content: Text(
          'Êtes-vous sûr de vouloir vider toute la base de données locale ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Vider', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final db = ref.watch(databaseProvider);

      // Supprimer dans l'ordre inverse des dépendances
      await db.paiementFraisDao.deleteAllPaiementsFrais();
      await db.fraisScolaireDao.deleteAllFraisScolaires();
      await db.compteComptableDao.deleteAllComptesComptables();
      await db.comptesConfigDao.deleteAllComptesConfigs();
      await db.journalComptableDao.deleteAllJournauxComptables();
      await db.depenseDao.deleteAllDepenses();
      await db.eleveDao.deleteAllEleves();
      await db.responsableDao.deleteAllResponsables();
      await db.classeDao.deleteAllClasses();
      await db.anneeScolaireDao.deleteAllAnneesScolaires();
      await db.utilisateurDao.deleteAllUtilisateurs();
      await db.entrepriseDao.deleteAllEntreprises();

      print('✅ Base de données vidée avec succès');

      setState(() {
        _errorMessage =
            'Base de données vidée avec succès. Vous pouvez maintenant vous reconnecter.';
      });
    } catch (e) {
      print('❌ Erreur lors du vidage: $e');
      setState(() {
        _errorMessage = 'Erreur lors du vidage: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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

              // Champ email/username
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Email / Nom d\'utilisateur',
                  labelStyle: const TextStyle(color: AyannaColors.darkGrey),
                  filled: true,
                  fillColor: AyannaColors.white,
                  prefixIcon: const Icon(
                    Icons.email,
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

              // Champ mot de passe
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  labelStyle: const TextStyle(color: AyannaColors.darkGrey),
                  filled: true,
                  fillColor: AyannaColors.white,
                  prefixIcon: const Icon(
                    Icons.lock,
                    color: AyannaColors.orange,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: AyannaColors.orange,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
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

              // Message d'erreur
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: _errorMessage!.contains('succès')
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _errorMessage!.contains('succès')
                          ? Colors.green.shade300
                          : Colors.red.shade300,
                    ),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: _errorMessage!.contains('succès')
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Bouton de connexion
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AyannaColors.white,
                          ),
                        )
                      : const Icon(Icons.login, color: AyannaColors.white),
                  label: Text(_isLoading ? 'Connexion...' : 'Se connecter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AyannaColors.orange,
                    foregroundColor: AyannaColors.white,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isLoading ? null : _login,
                ),
              ),

              const SizedBox(height: 16),

              // Boutons de développement
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _fetchUserInfo,
                    icon: Icon(Icons.info_outline, size: 16),
                    label: Text('Infos API', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AyannaColors.orange,
                      minimumSize: Size(0, 36),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _clearLocalDatabase,
                    icon: Icon(Icons.delete_forever, size: 16),
                    label: Text('Vider BD', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      minimumSize: Size(0, 36),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Information
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  'LOGIQUE:\n'
                  '• BD vide → API directe + import\n'
                  '• BD non vide → Vérification locale\n'
                  '\n'
                  'Boutons debug ci-dessus pour tests.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.blue.shade700),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
