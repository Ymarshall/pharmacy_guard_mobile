import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/themes/colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../shared/styles/text_styles.dart';
import '../providers/auth_notifier.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/permission_service.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();
    setState(() => _isLoading = true);

    // Tenter de se connecter
    await ref.read(authNotifierProvider.notifier).loginWithPhone(phone);

    final authState = ref.read(authNotifierProvider);
    setState(() => _isLoading = false);

    if (authState.needsLocation) {
      // Le client n'existe pas, on doit demander la géolocalisation via un popup
      _showLocationPermissionDialog(phone);
    } else if (authState.isAuthenticated) {
      // Connexion réussie
      if (mounted) {
        context.navigateToAndRemoveUntil(AppRoutes.home);
      }
    } else if (authState.error != null) {
      // Erreur de connexion
      if (mounted) {
        context.showErrorSnackBar(authState.error!);
      }
    }
  }

  void _showLocationPermissionDialog(String phone) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.location_on, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Activer la géolocalisation',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: const Text(
            'Pour créer votre compte, nous avons besoin de votre position. '
            'Cela nous permet de vous proposer les pharmacies de garde les plus proches de vous.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                setState(() => _isLoading = false);
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _requestLocationAndCreateAccount(phone);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Activer'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _requestLocationAndCreateAccount(String phone) async {
    if (!mounted) return;

    // Vérifier d'abord si la permission est déjà accordée
    final permissionService = PermissionServiceImpl();
    bool hasPermission = await permissionService.checkLocationPermission();

    if (!hasPermission) {
      // Demander la permission de géolocalisation
      hasPermission = await permissionService.requestLocationPermission();
    }

    if (!hasPermission) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text('Permission requise'),
              content: const Text(
                'La géolocalisation est nécessaire pour créer votre compte. '
                'Veuillez autoriser l\'accès à votre position dans les paramètres de l\'application.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
      return;
    }

    // Afficher un loader pendant l'enregistrement
    if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return PopScope(
              canPop: false,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Enregistrement en cours...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Création de votre compte',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
    }

    // Obtenir la position et créer le compte
    try {
      // Mettre à jour le message du loader
      if (mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return PopScope(
              canPop: false,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Récupération de votre position...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }

      final locationService = LocationServiceImpl();
      final position = await locationService.getCurrentLocation();

      // Mettre à jour le message du loader
      if (mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return PopScope(
              canPop: false,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Enregistrement en cours...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Création de votre compte',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }

      // Créer le compte avec la position
      await ref.read(authNotifierProvider.notifier).createClientAndLogin(
            phone: phone,
            latitude: position.latitude,
            longitude: position.longitude,
          );

      // Fermer le loader
      if (mounted) {
        Navigator.pop(context);
      }

      final authState = ref.read(authNotifierProvider);

      if (authState.isAuthenticated) {
        if (mounted) {
          // Afficher un message de succès brièvement avant la redirection
          context.showSnackBar('Compte créé avec succès !');
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            context.navigateToAndRemoveUntil(AppRoutes.home);
          }
        }
      } else if (authState.error != null) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: const Text('Erreur'),
                content: Text(authState.error!),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      // Fermer le loader en cas d'erreur
      if (mounted) {
        Navigator.pop(context);
      }
      
      String errorMessage = 'Erreur lors de la création de votre compte';
      
      // Messages d'erreur plus explicites
      if (e.toString().contains('location') || e.toString().contains('position')) {
        errorMessage = 'Impossible de récupérer votre position.\n\n'
            'Sur le simulateur, vous devez configurer une position :\n'
            '• iOS Simulator : Features > Location > Custom Location...\n'
            '• Android Emulator : Utilisez les contrôles de localisation dans la barre latérale';
      } else {
        errorMessage = 'Erreur : ${e.toString()}';
      }
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text('Erreur'),
              content: Text(errorMessage),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    _isLoading = authState.isLoading || _isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.05),
              AppColors.background,
              AppColors.background,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  // Logo
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.1),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.local_pharmacy,
                        size: 50,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Title
                  Text(
                    'Connexion',
                    style: TextStyles.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Entrez votre numéro de téléphone',
                    style: TextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  // Phone field
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    enabled: !_isLoading,
                    style: TextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Numéro de téléphone',
                      labelStyle: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                      hintText: '+225 07 12 34 56 78',
                      hintStyle: TextStyle(
                        color: AppColors.textTertiary,
                      ),
                      prefixIcon: Icon(
                        Icons.phone_outlined,
                        color: AppColors.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre numéro de téléphone';
                      }
                      // Validation basique du numéro
                      final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
                      if (cleaned.length < 8) {
                        return 'Numéro de téléphone invalide';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 24),
                // Submit button
                AppButton(
                  text: _isLoading ? 'Connexion...' : 'Se connecter',
                  onPressed: _isLoading ? null : _handleLogin,
                  icon: Icons.login_outlined,
                ),
                if (authState.error != null && !authState.needsLocation) ...[
                  const SizedBox(height: 16),
                  Text(
                    authState.error!,
                    style: TextStyles.bodySmall.copyWith(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    )
    );
  }
}
