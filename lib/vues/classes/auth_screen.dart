import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/sync_manager.dart';
import '../../services/database_service.dart';
import '../../services/school_queries.dart';
import '../../models/auth_result.dart';
import '../../theme/ayanna_theme.dart';
import '../widgets/ayanna_widgets.dart';
import '../../models/models.dart';
import 'package:ayanna_school/vues/gestions%20frais/paiement_frais.dart';

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
  final _emailController = TextEditingController(text: 'admin@collegeleparadoxe.com');
  final _passwordController = TextEditingController(text: '123456');
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _errorMessage;

  /// Vérifie si la base de données locale est vide
  Future<bool> _isDatabaseEmpty() async {
    print('=== VÉRIFICATION BASE DE DONNÉES LOCALE ===');
    try {
      final entreprises = await SchoolQueries.getAllEntreprises();
      final utilisateurs = await SchoolQueries.getAllUtilisateurs();
      final anneesScol = await SchoolQueries.getAllAnneesScolaires();

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
      return true; // Considérer comme vide en cas d'erreur
    }
  }

  /// Vérifie l'authentification dans la base locale
  Future<bool> _authenticateLocally(String email, String password) async {
    print('=== AUTHENTIFICATION LOCALE ===');
    print('Email: $email');
    print(
      'Password: ${password.substring(0, math.min(10, password.length))}...',
    );

    try {
      final utilisateurs = await SchoolQueries.getAllUtilisateurs();
      print('📊 ${utilisateurs.length} utilisateurs dans la BD locale');

      // Chercher l'utilisateur par nom (en supposant que le nom correspond à l'email)
      Utilisateur? utilisateur;
      for (final u in utilisateurs) {
        if (u.nom.toLowerCase() == email.toLowerCase() ||
            u.nom.toLowerCase() == email.split('@').first.toLowerCase()) {
          utilisateur = u;
          break;
        }
      }

      if (utilisateur == null) {
        print('❌ Utilisateur non trouvé localement');
        return false;
      }

      print('✅ Utilisateur trouvé: ${utilisateur.nom}');
      print('🔐 Vérification mot de passe...');

      // Vérification du mot de passe
      bool passwordMatch = utilisateur.motDePasse == password;

      if (passwordMatch) {
        print('✅ Authentification locale RÉUSSIE');
        return true;
      } else {
        print('❌ Mot de passe incorrect');
        return false;
      }
    } catch (e) {
      print('❌ Erreur authentification locale: $e');
      return false;
    }
  }

  /// Authentification complète via l'API avec importation des données
  Future<bool> _authenticateViaAPI(String email, String password) async {
    print('=== AUTHENTIFICATION VIA API ===');

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final syncManager = Provider.of<SyncManager>(context, listen: false);

      // Étape 1: Authentification avec l'API
      print('🔐 Authentification avec l\'API...');
      final authResult = await authService.login(email, password: password);

      if (authResult is AuthSuccess) {
        print('✅ Authentification API réussie');
        print(
          'Token reçu: ${authResult.token.length} caractères${authResult.token.length > 10 ? " (${authResult.token.substring(0, 10)}...)" : " (${authResult.token})"}',
        );

        // Étape 2: Configuration de l'authentification dans le SyncManager
        syncManager.setAuth(authResult.token, email);

        // Étape 3: Importation complète des données depuis le serveur
        print('📥 Importation complète des données...');
        final importSuccess = await syncManager.importAllDataFromServer(
          clearExisting: true, // Vider les données existantes
        );

        if (!importSuccess) {
          print('❌ Échec de l\'importation des données');
          setState(() {
            _errorMessage =
                'Erreur lors de l\'importation des données depuis le serveur';
          });
          return false;
        }

        print('✅ Importation complète terminée avec succès');
        return true;
      } else if (authResult is AuthError) {
        print('❌ Échec authentification API: ${authResult.message}');
        setState(() {
          _errorMessage = 'Erreur API: ${authResult.message}';
        });
        return false;
      }
    } catch (e, stackTrace) {
      print('❌ Exception authentification API: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _errorMessage = 'Erreur de connexion API: $e';
      });
      return false;
    }

    return false;
  }

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

      // Étape 1: Vérifier si la base de données est vide
      final isDatabaseEmpty = await _isDatabaseEmpty();

      if (isDatabaseEmpty) {
        print('🗂️ BASE DE DONNÉES VIDE - Authentification via API');

        // Base vide: authentifier directement via l'API et importer toutes les données
        final apiAuthSuccess = await _authenticateViaAPI(email, password);

        if (apiAuthSuccess) {
          print('✅ CONNEXION RÉUSSIE (via API)');
          if (mounted) {
            // Navigation vers l'écran en fonction du contexte
            if (widget.navigateToClasses) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => PaiementDesFrais()),
              );
            } else {
              Navigator.of(context).pushReplacementNamed('/home');
            }
          }
        }
        // Si échec, le message d'erreur a déjà été défini dans _authenticateViaAPI
      } else {
        print('🗂️ BASE DE DONNÉES NON VIDE - Vérification locale en premier');

        // Base non vide: vérifier d'abord localement
        final localAuthSuccess = await _authenticateLocally(email, password);

        if (localAuthSuccess) {
          print('✅ CONNEXION RÉUSSIE (authentification locale)');
          if (mounted) {
            // Navigation vers l'écran en fonction du contexte
            if (widget.navigateToClasses) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => PaiementDesFrais()),
              );
            } else {
              Navigator.of(context).pushReplacementNamed('/home');
            }
          }
        } else {
          print('❌ Authentification locale échouée');
          setState(() {
            _errorMessage = 'Email ou mot de passe incorrect';
          });
        }
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
      final authService = Provider.of<AuthService>(context, listen: false);
      print('AuthService récupéré, appel getUserFromServer...');

      final userData = await authService.getUserFromServer(
        _emailController.text.trim(),
      );

      print('Réponse getUserFromServer: $userData');

      if (userData != null) {
        print('Données utilisateur reçues, affichage dialog...');
        // Afficher les informations dans une boîte de dialogue
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Informations utilisateur'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Nom: ${userData['nom'] ?? 'N/A'}'),
                    Text('Prénom: ${userData['prenom'] ?? 'N/A'}'),
                    Text('Email: ${userData['email'] ?? 'N/A'}'),
                    Text('Rôle: ${userData['role'] ?? 'N/A'}'),
                    Text('Actif: ${userData['actif'] == 1 ? 'Oui' : 'Non'}'),
                    SizedBox(height: 8),
                    Text('Hash du mot de passe:'),
                    SelectableText(
                      userData['mot_de_passe_hash'] ??
                          userData['password'] ??
                          'Non disponible',
                      style: TextStyle(fontSize: 10, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Copier le hash dans le champ mot de passe pour test
                    if (userData['mot_de_passe_hash'] != null) {
                      _passwordController.text = userData['mot_de_passe_hash'];
                    } else if (userData['password'] != null) {
                      _passwordController.text = userData['password'];
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text('Utiliser ce hash'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Fermer'),
                ),
              ],
            ),
          );
        }
      } else {
        print('Aucune donnée utilisateur reçue');
        setState(() {
          _errorMessage = 'Utilisateur non trouvé sur le serveur';
        });
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
      final db = await DatabaseService.database;

      // Supprimer dans l'ordre inverse des dépendances
      await db.delete('paiement_frais');
      await db.delete('frais_scolaires');
      await db.delete('comptes_comptables');
      await db.delete('comptes_config');
      await db.delete('journal_comptable');
      await db.delete('depenses');
      await db.delete('eleves');
      await db.delete('responsables');
      await db.delete('classes');
      await db.delete('annees_scolaires');
      await db.delete('utilisateurs');
      await db.delete('entreprises');

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
