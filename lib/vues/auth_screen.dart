// import 'dart:math' as math;
import 'package:ayanna_school/models/entities/annee_scolaire.dart';
// import 'package:ayanna_school/models/entities/utilisateur.dart';
import 'package:ayanna_school/vues/gestions%20frais/paiement_frais.dart';
import 'package:ayanna_school/services/licence/licence_validator.dart';
import 'package:ayanna_school/vues/licence_reactivation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/providers/providers.dart';

import '../theme/ayanna_theme.dart';
import 'widgets/ayanna_widgets.dart';

/// Statuts possibles du bouton de connexion
enum ButtonStatus {
  chargementDonnees, // Premier démarrage: charger les données
  validationLicence, // Après chargement: valider la licence
  connexion, // Licence valide: se connecter
  enregistrement, // Pas de mot de passe local: enregistrer
}

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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _errorMessage;
  bool _showLogoutMessage = false;
  bool _isFirstLaunch = true; // Mode inscription par défaut
  bool _isCheckingFirstLaunch = true;
  int _loadingProgress = 0; // Pourcentage de chargement (0-100)
  ButtonStatus _buttonStatus = ButtonStatus.chargementDonnees; // Statut initial
  bool _hasDataLoaded = false; // Indique si les données ont été chargées

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
    _checkAuthenticationStatus();
  }

  /// Vérifie si c'est le premier démarrage de l'application
  Future<void> _checkFirstLaunch() async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      final hasLocalPassword = prefs.getString('local_password') != null;
      final savedEmail = prefs.getString('local_email');
      final hasDataLoaded = prefs.getBool('has_data_loaded') ?? false;

      setState(() {
        _isFirstLaunch = !hasLocalPassword;
        _hasDataLoaded = hasDataLoaded;
        _isCheckingFirstLaunch = false;

        // Déterminer le statut du bouton
        if (_isFirstLaunch) {
          // Premier démarrage : toujours commencer par l'enregistrement du mot de passe
          _buttonStatus = ButtonStatus.enregistrement;
        } else if (!hasDataLoaded) {
          _buttonStatus = ButtonStatus.chargementDonnees;
        } else {
          // Données chargées, passer à la validation de licence
          _buttonStatus = ButtonStatus.validationLicence;
        }

        // Pré-remplir l'email si disponible
        if (savedEmail != null && !_isFirstLaunch) {
          _emailController.text = savedEmail;
        }
      });

      print('🔍 [AUTH] Premier démarrage: $_isFirstLaunch');
      print('🔍 [AUTH] Données chargées: $hasDataLoaded');
      print('🔍 [AUTH] Statut du bouton: $_buttonStatus');
    } catch (e) {
      print('❌ [AUTH] Erreur vérification premier démarrage: $e');
      setState(() {
        _isFirstLaunch = true;
        _hasDataLoaded = false;
        _buttonStatus = ButtonStatus.chargementDonnees;
        _isCheckingFirstLaunch = false;
      });
    }
  }

  /// Vérifie l'état d'authentification pour afficher un message approprié
  Future<void> _checkAuthenticationStatus() async {
    print('🔍 [AUTH_SCREEN] Vérification de l\'état d\'authentification...');

    try {
      final authStateAsync = ref.read(authNotifierProvider);
      print('🔍 [AUTH_SCREEN] État AsyncValue: $authStateAsync');

      // Vérifier si on a une valeur et si l'utilisateur n'est pas connecté
      authStateAsync.whenData((authState) {
        print(
          '🔍 [AUTH_SCREEN] État actuel d\'authentification: isAuthenticated=${authState.isAuthenticated}',
        );

        // Si l'utilisateur n'est pas connecté, afficher le message de déconnexion
        if (!authState.isAuthenticated && authState.token == null) {
          setState(() {
            _showLogoutMessage = true;
            _errorMessage = 'Déconnexion réussie. Veuillez vous reconnecter.';
          });
          print('✅ [AUTH_SCREEN] Message de déconnexion affiché');
        }
      });
    } catch (e) {
      print(
        '❌ [AUTH_SCREEN] Erreur lors de la vérification d\'authentification: $e',
      );
    }
  }

  // Debug helpers exist elsewhere; removed unused _isDatabaseEmpty to reduce warnings.

  /// Charge les données initiales depuis le serveur
  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _loadingProgress = 0;
    });

    try {
      print('📥 [AUTH] Début du chargement des données...');

      // Étape 1: Connexion au serveur (0-30%)
      setState(() => _loadingProgress = 10);

      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final loginSuccess = await ref
          .read(authNotifierProvider.notifier)
          .login(email, password);

      if (!loginSuccess) {
        setState(() {
          _errorMessage = 'Échec de la connexion au serveur';
          _loadingProgress = 0;
          _isLoading = false;
        });
        return;
      }

      print('✅ [AUTH] Connexion réussie');
      setState(() => _loadingProgress = 30);

      // Étape 2: Chargement des données (30-90%)
      print('📥 [AUTH] Chargement des données...');

      // Ici vous pouvez ajouter la logique pour charger les données
      // Par exemple : ref.read(syncNotifierProvider.notifier).syncAllData()
      await Future.delayed(const Duration(seconds: 2)); // Simulation

      setState(() => _loadingProgress = 90);

      // Étape 3: Sauvegarder le flag de chargement (90-100%)
      final prefs = await ref.read(sharedPreferencesProvider.future);
      await prefs.setBool('has_data_loaded', true);

      setState(() {
        _loadingProgress = 100;
        _hasDataLoaded = true;
        _buttonStatus = ButtonStatus.validationLicence;
        _isLoading = false;
      });

      print('✅ [AUTH] Données chargées avec succès');

      // Maintenant vérifier la licence
      await _checkLicenceAndProceed();
    } catch (e) {
      print('❌ [AUTH] Erreur lors du chargement des données: $e');
      setState(() {
        _errorMessage = 'Erreur lors du chargement des données: $e';
        _loadingProgress = 0;
        _isLoading = false;
      });
    }
  }

  /// Vérifie la licence et procède à la navigation appropriée
  Future<void> _checkLicenceAndProceed() async {
    setState(() {
      _isLoading = true;
      _loadingProgress = 60;
    });

    try {
      print('🔍 [AUTH] Vérification de la licence...');

      final licenceState = await ref.read(licenceValidationProvider.future);
      setState(() => _loadingProgress = 80);

      if (licenceState.shouldBlockApp && licenceState.licence != null) {
        // ❌ Licence invalide/expirée - Rediriger vers réactivation
        print('❌ [AUTH] Licence invalide ou expirée');
        setState(() {
          _buttonStatus = ButtonStatus.validationLicence;
          _isLoading = false;
          _loadingProgress = 100;
        });

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LicenceReactivationScreen(
                licence: licenceState.licence!,
                onLicenceReactivated: () {
                  // Navigation déjà gérée par l'invalidation du provider
                  Navigator.pushReplacementNamed(context, '/home');
                },
              ),
            ),
          );
        }
        return;
      } else if (!licenceState.isValid && licenceState.licence == null) {
        // Vérifier dans la base locale
        print('🔍 [AUTH] Vérification de la licence en base locale...');
        setState(() => _loadingProgress = 85);

        if (mounted) {
          try {
            final licenceDao = ref.read(licenceDaoProvider);
            final entrepriseDao = ref.read(entrepriseDaoProvider);

            final entreprises = await entrepriseDao.getAllEntreprises();
            setState(() => _loadingProgress = 90);

            final entreprise = entreprises.first;
            final licences = await licenceDao.getAllLicences();
            setState(() => _loadingProgress = 95);

            final licencesEntreprise = licences
                .where((l) => l.entrepriseId == entreprise.id)
                .toList();

            if (licencesEntreprise.isNotEmpty) {
              final licence = licencesEntreprise.first;
              print(
                '🔑 [AUTH] Licence trouvée - Redirection vers réactivation',
              );

              setState(() => _loadingProgress = 100);

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LicenceReactivationScreen(
                    licence: licence,
                    onLicenceReactivated: () {
                      // Navigation déjà gérée par l'invalidation du provider
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                  ),
                ),
              );
            } else {
              print('❌ [AUTH] Aucune licence trouvée');
              setState(() {
                _errorMessage =
                    'Aucune licence trouvée. Contactez l\'administrateur.';
                _loadingProgress = 0;
                _isLoading = false;
              });
            }
          } catch (e) {
            print('❌ [AUTH] Erreur vérification licence locale: $e');
            setState(() {
              _errorMessage =
                  'Erreur lors de la vérification de la licence: $e';
              _loadingProgress = 0;
              _isLoading = false;
            });
          }
        }
        return;
      }

      // ✅ Licence valide - Permettre la connexion
      print('✅ [AUTH] Licence valide');
      setState(() {
        _buttonStatus = ButtonStatus.connexion;
        _loadingProgress = 100;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ [AUTH] Erreur vérification licence: $e');
      setState(() {
        _errorMessage = 'Erreur lors de la vérification de la licence: $e';
        _loadingProgress = 0;
        _isLoading = false;
      });
    }
  }

  /// Vérifie l'authentification dans la base locale

  Future<void> _login() async {
    // Validation des champs
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez saisir votre email';
      });
      return;
    }

    // Gérer selon le statut du bouton
    switch (_buttonStatus) {
      case ButtonStatus.chargementDonnees:
        // Charger les données initiales
        await _loadInitialData();
        break;

      case ButtonStatus.validationLicence:
        // Vérifier la licence et procéder
        await _checkLicenceAndProceed();
        break;

      case ButtonStatus.enregistrement:
        // Premier démarrage - Enregistrer le mot de passe
        if (_passwordController.text.trim().isEmpty) {
          setState(() {
            _errorMessage = 'Veuillez saisir votre mot de passe';
          });
          return;
        }

        if (_confirmPasswordController.text.trim().isEmpty) {
          setState(() {
            _errorMessage = 'Veuillez confirmer votre mot de passe';
          });
          return;
        }

        if (_passwordController.text.trim() !=
            _confirmPasswordController.text.trim()) {
          setState(() {
            _errorMessage = 'Les mots de passe ne correspondent pas';
          });
          return;
        }

        if (_passwordController.text.trim().length < 6) {
          setState(() {
            _errorMessage =
                'Le mot de passe doit contenir au moins 6 caractères';
          });
          return;
        }

        await _registerLocalPassword();
        break;

      case ButtonStatus.connexion:
        // Connexion normale - Vérifier le mot de passe local
        if (_passwordController.text.trim().isEmpty) {
          setState(() {
            _errorMessage = 'Veuillez saisir votre mot de passe';
          });
          return;
        }

        await _performLogin();
        break;
    }
  }

  /// Effectue la connexion normale après validation de la licence
  Future<void> _performLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _loadingProgress = 0;
    });

    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      final savedPassword = prefs.getString('local_password');
      final savedEmail = prefs.getString('local_email');

      // Vérifier le mot de passe
      if (savedPassword == null) {
        setState(() {
          _errorMessage =
              'Aucun mot de passe enregistré. Veuillez réinstaller l\'application.';
          _isLoading = false;
        });
        return;
      }

      if (savedEmail != _emailController.text.trim() ||
          savedPassword != _passwordController.text.trim()) {
        setState(() {
          _errorMessage = 'Email ou mot de passe incorrect';
          _isLoading = false;
        });
        return;
      }

      // Mot de passe correct, continuer avec la connexion au serveur
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      print('=== DÉBUT PROCESSUS DE CONNEXION ===');
      print('Email: $email');

      // Étape 1: Connexion (0-50%)
      setState(() => _loadingProgress = 10);

      final loginSuccess = await ref
          .watch(authNotifierProvider.notifier)
          .login(email, password);

      if (loginSuccess) {
        print('✅ Connexion réussie');
        setState(() => _loadingProgress = 50);

        // 🔐 VÉRIFICATION DE LA LICENCE AVANT NAVIGATION
        print('🔍 Vérification de la licence après connexion...');
        setState(() => _loadingProgress = 60);

        final licenceState = await ref.read(licenceValidationProvider.future);

        setState(() => _loadingProgress = 80);

        if (licenceState.shouldBlockApp && licenceState.licence != null) {
          // ❌ Licence invalide/expirée - Bloquer l'accès
          print('❌ Licence invalide ou expirée - Accès bloqué');
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LicenceReactivationScreen(
                  licence: licenceState.licence!,
                  onLicenceReactivated: () {
                    // Navigation déjà gérée par l'invalidation du provider
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                ),
              ),
            );
          }
          return;
        } else if (!licenceState.isValid && licenceState.licence == null) {
          // ❌ Aucune licence trouvée - Vérifier dans la table locale
          print(
            '❌ Aucune licence trouvée dans le provider - Vérification table locale...',
          );
          setState(() => _loadingProgress = 85);

          if (mounted) {
            try {
              // Vérifier directement dans la table locale
              final licenceDao = ref.read(licenceDaoProvider);
              final entrepriseDao = ref.read(entrepriseDaoProvider);

              final entreprises = await entrepriseDao.getAllEntreprises();
              setState(() => _loadingProgress = 90);

              // if (entreprises.isEmpty) {
              //   setState(() {
              //     _errorMessage =
              //         'Aucune entreprise trouvée. Veuillez synchroniser les données.';
              //     _loadingProgress = 0;
              //   });
              //   return;
              // }

              final entreprise = entreprises.first;
              final licences = await licenceDao.getAllLicences();
              setState(() => _loadingProgress = 95);

              // Filtrer les licences par entreprise_id
              final licencesEntreprise = licences
                  .where((l) => l.entrepriseId == entreprise.id)
                  .toList();

              print(
                '📊 Licences trouvées pour entreprise ${entreprise.id}: ${licencesEntreprise.length}',
              );

              if (licencesEntreprise.isNotEmpty) {
                // Il y a une licence en base locale - rediriger vers écran de réactivation
                final licence = licencesEntreprise.first;
                print(
                  '🔑 Licence trouvée en base locale - Redirection vers écran de réactivation',
                );

                setState(() => _loadingProgress = 100);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LicenceReactivationScreen(
                      licence: licence,
                      onLicenceReactivated: () {
                        // Navigation déjà gérée par l'invalidation du provider
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                    ),
                  ),
                );
              } else {
                // Aucune licence en base locale - afficher message d'erreur
                print('❌ Aucune licence trouvée en base locale');
                setState(() {
                  _errorMessage =
                      'Aucune licence trouvée. Contactez l\'administrateur pour obtenir une licence.';
                  _loadingProgress = 0;
                });
              }
            } catch (e) {
              print('❌ Erreur vérification licence locale: $e');
              setState(() {
                _errorMessage =
                    'Erreur lors de la vérification de la licence: $e';
                _loadingProgress = 0;
              });
            }
          }
          return;
        }

        // ✅ Licence valide - Autoriser la navigation
        print('✅ Licence valide - Navigation autorisée');
        setState(() => _loadingProgress = 100);

        if (mounted) {
          if (widget.navigateToClasses && widget.anneeScolaire != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PaiementDesFrais(anneeScolaire: widget.anneeScolaire),
              ),
            );
          } else {
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
      } else {
        print('❌ Échec de la connexion');
        setState(() {
          _errorMessage =
              'Échec de la connexion au serveur. Veuillez réessayer.';
          _loadingProgress = 0;
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

  /// Enregistre le mot de passe local lors de la première inscription
  Future<void> _registerLocalPassword() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Sauvegarder le mot de passe local
      final prefs = await ref.read(sharedPreferencesProvider.future);
      await prefs.setString('local_email', email);
      await prefs.setString('local_password', password);

      print('✅ Mot de passe local enregistré');

      // Vérifier si les données ont déjà été chargées
      final hasDataLoaded = prefs.getBool('has_data_loaded') ?? false;

      // Passer au statut suivant
      setState(() {
        _isFirstLaunch = false;
        _isLoading = false;
        _confirmPasswordController.clear();

        // Déterminer le prochain statut
        if (!hasDataLoaded) {
          _buttonStatus = ButtonStatus.chargementDonnees;
          _errorMessage =
              'Mot de passe enregistré ! Cliquez sur "Charger les données".';
        } else {
          _buttonStatus = ButtonStatus.validationLicence;
          _errorMessage =
              'Mot de passe enregistré ! Cliquez sur "Valider la licence".';
        }
      });

      // Message de succès
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mot de passe enregistré avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Erreur enregistrement mot de passe: $e');
      setState(() {
        _errorMessage = 'Erreur lors de l\'enregistrement: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _login_old() async {
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
      // refresh preferences notifier if needed
      // await ref.read(syncPreferencesNotifierProvider.notifier).clearSyncData();
      final loginSuccess = await ref
          .watch(authNotifierProvider.notifier)
          .login(email, password);

      if (loginSuccess) {
        print('✅ Connexion réussie');

        // After successful login, if first-launch password setup is required,
        // prompt the user to set a local password.
        try {
          final prefs = await ref.read(sharedPreferencesProvider.future);
          final requiresSetup =
              prefs.getBool('requires_password_setup') ?? false;
          if (requiresSetup) {
            // Prompt for password setup
            await _promptSetPassword(_emailController.text.trim());
          }
        } catch (e) {
          print('⚠️ Erreur vérification require password setup: $e');
        }

        // Naviguer vers l'écran principal
        if (widget.navigateToClasses && widget.anneeScolaire != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PaiementDesFrais(anneeScolaire: widget.anneeScolaire),
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

  Future<void> _promptSetPassword(String email) async {
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    String? error;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Définir un mot de passe local'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Mot de passe (min 6)'),
              ),
              TextField(
                controller: confirmController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirmer le mot de passe',
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(error!, style: TextStyle(color: Colors.red)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                final p = passwordController.text.trim();
                final c = confirmController.text.trim();
                if (p.length < 6) {
                  setState(
                    () => error =
                        'Le mot de passe doit contenir au moins 6 caractères',
                  );
                  return;
                }
                if (p != c) {
                  setState(
                    () => error = 'Les mots de passe ne correspondent pas',
                  );
                  return;
                }

                // Call provider to set local password
                final authNotifier = ref.read(authNotifierProvider.notifier);
                final ok = await authNotifier.setLocalPassword(email, p);
                if (ok) {
                  Navigator.of(context).pop(true);
                } else {
                  setState(
                    () => error =
                        'Erreur lors de l\'enregistrement du mot de passe',
                  );
                }
              },
              child: Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      // Optionally show a small snackbar
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mot de passe local défini avec succès')),
        );
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
    // Afficher un loader pendant la vérification du premier démarrage
    if (_isCheckingFirstLaunch) {
      return const Scaffold(
        backgroundColor: AyannaColors.lightGrey,
        body: Center(
          child: CircularProgressIndicator(color: AyannaColors.orange),
        ),
      );
    }

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
              Text(
                _isFirstLaunch ? 'Première connexion' : 'Connexion',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (_isFirstLaunch)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Créez votre mot de passe local',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
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
                  labelText: _isFirstLaunch
                      ? 'Mot de passe (min 6 caractères)'
                      : 'Mot de passe',
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

              // Champ confirmer mot de passe (uniquement au premier démarrage)
              if (_isFirstLaunch) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le mot de passe',
                    labelStyle: const TextStyle(color: AyannaColors.darkGrey),
                    filled: true,
                    fillColor: AyannaColors.white,
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AyannaColors.orange,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AyannaColors.orange,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
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
              ],

              const SizedBox(height: 24),

              // Message d'erreur ou de déconnexion
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color:
                        _errorMessage!.contains('enregistré') ||
                            _errorMessage!.contains('✅')
                        ? Colors.green.shade100
                        : _showLogoutMessage ||
                              _errorMessage!.contains('Déconnexion réussie')
                        ? Colors.blue.shade100
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          _errorMessage!.contains('enregistré') ||
                              _errorMessage!.contains('✅')
                          ? Colors.green.shade300
                          : _showLogoutMessage ||
                                _errorMessage!.contains('Déconnexion réussie')
                          ? Colors.blue.shade300
                          : Colors.red.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _errorMessage!.contains('enregistré') ||
                                _errorMessage!.contains('✅')
                            ? Icons.check_circle
                            : _showLogoutMessage ||
                                  _errorMessage!.contains('Déconnexion réussie')
                            ? Icons.logout
                            : Icons.error,
                        color:
                            _errorMessage!.contains('enregistré') ||
                                _errorMessage!.contains('✅')
                            ? Colors.green.shade700
                            : _showLogoutMessage ||
                                  _errorMessage!.contains('Déconnexion réussie')
                            ? Colors.blue.shade700
                            : Colors.red.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color:
                                _errorMessage!.contains('enregistré') ||
                                    _errorMessage!.contains('✅')
                                ? Colors.green.shade700
                                : _showLogoutMessage ||
                                      _errorMessage!.contains(
                                        'Déconnexion réussie',
                                      )
                                ? Colors.blue.shade700
                                : Colors.red.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

              // Bouton de connexion
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AyannaColors.orange,
                    foregroundColor: AyannaColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Chargement... $_loadingProgress%',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_getButtonIcon()),
                            const SizedBox(width: 8),
                            Text(
                              _getButtonText(),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Retourne l'icône appropriée selon le statut du bouton
  IconData _getButtonIcon() {
    switch (_buttonStatus) {
      case ButtonStatus.chargementDonnees:
        return Icons.download;
      case ButtonStatus.validationLicence:
        return Icons.verified_user;
      case ButtonStatus.enregistrement:
        return Icons.app_registration;
      case ButtonStatus.connexion:
        return Icons.login;
    }
  }

  /// Retourne le texte approprié selon le statut du bouton
  String _getButtonText() {
    switch (_buttonStatus) {
      case ButtonStatus.chargementDonnees:
        return 'Charger les données';
      case ButtonStatus.validationLicence:
        return 'Valider la licence';
      case ButtonStatus.enregistrement:
        return 'Enregistrer';
      case ButtonStatus.connexion:
        return 'Se connecter';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
