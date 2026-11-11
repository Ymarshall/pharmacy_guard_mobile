import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../shared/widgets/icon_chip.dart';
import '../../../../shared/widgets/input_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/providers/providers.dart';
import '../providers/auth_notifier.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/utils/ivorian_phone.dart';
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

  bool _resumePendingAction() {
    final gate = ref.read(reconnectGateProvider);
    if (!gate.isWaiting) return false;
    gate.succeed();
    if (mounted) Navigator.of(context).maybePop();
    return true;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();
    setState(() => _isLoading = true);

    // Tenter de se connecter
    await ref.read(authNotifierProvider.notifier).loginWithPhone(phone);

    final authState = ref.read(authNotifierProvider);
    setState(() => _isLoading = false);

    if (authState.needsRegistration) {
      _showRegisterDialog(phone);
    } else if (authState.isAuthenticated && authState.needsLocation) {
      _showLocationPermissionDialog(phone);
    } else if (authState.isAuthenticated) {
      if (!_resumePendingAction()) {
        if (mounted) {
          context.navigateToAndRemoveUntil(AppRoutes.home);
        }
      }
    } else if (authState.phoneError == null && authState.error != null) {
      if (mounted) {
        context.showErrorSnackBar(authState.error!);
      }
    }
  }

  void _showRegisterDialog(String phone) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Créer un compte'),
          content: const Text(
            'Ce numéro n\'est pas encore inscrit. Nous créons votre compte, '
            'puis nous vous demanderons votre position pour les pharmacies proches.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _register(phone);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Créer'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _register(String phone) async {
    await ref.read(authNotifierProvider.notifier).registerClient(phone: phone);
    if (!mounted) return;
    final authState = ref.read(authNotifierProvider);
    if (authState.needsLocation && authState.isAuthenticated) {
      _showLocationPermissionDialog(phone);
      return;
    }
    if (authState.isAuthenticated) {
      if (!_resumePendingAction() && mounted) {
        context.navigateToAndRemoveUntil(AppRoutes.home);
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
            'Votre compte est créé. Autorisez la géolocalisation pour afficher '
            'les pharmacies de garde les plus proches.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                setState(() => _isLoading = false);
                if (ref.read(authNotifierProvider).isAuthenticated && mounted) {
                  context.navigateToAndRemoveUntil(AppRoutes.home);
                }
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
                  const CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 24),
                  const Text(
                    'Enregistrement en cours...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
                    const CircularProgressIndicator(color: AppColors.primary),
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
                    const CircularProgressIndicator(color: AppColors.primary),
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

      await ref
          .read(authNotifierProvider.notifier)
          .updateLocation(
            latitude: position.latitude,
            longitude: position.longitude,
          );

      // Fermer le loader
      if (mounted) {
        Navigator.pop(context);
      }

      final authState = ref.read(authNotifierProvider);

      if (authState.isAuthenticated && authState.error == null) {
        if (_resumePendingAction()) return;
        if (mounted) {
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
                      if (authState.isAuthenticated && mounted) {
                        context.navigateToAndRemoveUntil(AppRoutes.home);
                      }
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
      if (e.toString().contains('location') ||
          e.toString().contains('position')) {
        errorMessage =
            'Impossible de récupérer votre position.\n\n'
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
      backgroundColor: context.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.paddingLg,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.lg),
                      IconChip(
                        icon: Icons.local_pharmacy_outlined,
                        size: 56,
                        iconSize: 28,
                      ),
                      const SizedBox(height: AppSpacing.xl2),
                      Text(
                        'Connexion',
                        style: AppTypography.screenTitle.copyWith(
                          color: context.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Entrez votre numéro de téléphone pour trouver les pharmacies de garde près de vous.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl3),
                      InputField(
                        controller: _phoneController,
                        label: 'Numéro de téléphone',
                        hint: '+225 07 12 34 56 78',
                        keyboardType: TextInputType.phone,
                        enabled: !_isLoading,
                        prefixIcon: Icon(
                          Icons.phone_outlined,
                          color: context.primary,
                        ),
                        errorText: authState.phoneError,
                        onChanged: (_) {
                          if (ref.read(authNotifierProvider).phoneError != null) {
                            ref
                                .read(authNotifierProvider.notifier)
                                .clearPhoneError();
                          }
                        },
                        validator: IvorianPhone.validationMessage,
                      ),
                      if (authState.phoneError == null &&
                          authState.error != null &&
                          !authState.needsLocation &&
                          !authState.needsRegistration) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          authState.error!,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: context.error),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: PrimaryButton(
                label: _isLoading ? 'Connexion...' : 'Se connecter',
                icon: Icons.login_outlined,
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _handleLogin,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
