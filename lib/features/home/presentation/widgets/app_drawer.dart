import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/icon_chip.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../about/presentation/pages/about_page.dart';
import '../../../help/presentation/pages/help_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: context.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconChip(
                    icon: Icons.local_pharmacy_outlined,
                    size: 52,
                    iconSize: 26,
                    backgroundColor: context.primaryDark,
                    iconColor: Colors.white,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Pharmacie de Garde',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: context.onSurface,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Côte d\'Ivoire',
                    style: AppTypography.caption.copyWith(
                      color: context.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: context.divider, height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                children: [
                  _item(
                    context,
                    icon: Icons.home_outlined,
                    label: 'Accueil',
                    onTap: () => Navigator.pop(context),
                  ),
                  _item(
                    context,
                    icon: Icons.info_outline,
                    label: 'À propos',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutPage(),
                        ),
                      );
                    },
                  ),
                  _item(
                    context,
                    icon: Icons.settings_outlined,
                    label: 'Paramètres',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsPage(),
                        ),
                      );
                    },
                  ),
                  _item(
                    context,
                    icon: Icons.help_outline,
                    label: 'Aide',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HelpPage(),
                        ),
                      );
                    },
                  ),
                  _item(
                    context,
                    icon: Icons.logout_outlined,
                    label: 'Déconnexion',
                    color: context.error,
                    onTap: () {
                      Navigator.pop(context);
                      _showLogoutDialog(context, ref);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: AppSpacing.paddingLg,
              child: Text(
                'Version 1.0.0',
                style: AppTypography.caption.copyWith(
                  color: context.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final tint = color ?? context.primary;
    return ListTile(
      leading: IconChip(
        icon: icon,
        size: 40,
        iconSize: 18,
        backgroundColor: tint.withValues(alpha: 0.12),
        iconColor: tint,
      ),
      title: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: color ?? context.onSurface,
            ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Déconnexion'),
          content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _logout(context, ref);
              },
              child: Text(
                'Déconnexion',
                style: TextStyle(color: context.error),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authNotifierProvider.notifier).signOut();

      if (context.mounted) {
        context.navigateToAndRemoveUntil(AppRoutes.login);
      }
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar('Erreur lors de la déconnexion');
      }
    }
  }
}
