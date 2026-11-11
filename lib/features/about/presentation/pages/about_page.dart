import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_decorations.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../shared/styles/text_styles.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/icon_chip.dart';
import '../../../../shared/widgets/screen_app_bar.dart';
import '../../../../shared/widgets/surface_card.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      appBar: const ScreenAppBar(title: 'À propos'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo/Header
            Center(
              child: Column(
                children: [
                  const IconChip(
                    icon: Icons.local_pharmacy_outlined,
                    size: 72,
                    iconSize: 34,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Pharmacie de Garde',
                    style: TextStyles.displaySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version 1.0.0',
                    style: TextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Mission
            _buildSection(
              title: 'Mission de l\'application',
              icon: Icons.flag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notre mission est de faciliter l\'accès aux services pharmaceutiques d\'urgence en Côte d\'Ivoire.',
                    style: TextStyles.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildMissionItem(
                    'Accessibilité 24/7',
                    'Trouvez rapidement les pharmacies de garde disponibles près de chez vous, à tout moment.',
                  ),
                  const SizedBox(height: 12),
                  _buildMissionItem(
                    'Information fiable',
                    'Accédez à des informations précises et à jour sur les pharmacies, leurs horaires et leurs services.',
                  ),
                  const SizedBox(height: 12),
                  _buildMissionItem(
                    'Santé publique',
                    'Contribuer à améliorer l\'accès aux soins de santé en facilitant la localisation des pharmacies de garde.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Sources de données
            _buildSection(
              title: 'Sources de données',
              icon: Icons.data_object,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Les informations affichées dans cette application proviennent de sources officielles et vérifiées :',
                    style: TextStyles.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildSourceItem(
                    context,
                    'Ordre National des Pharmaciens de Côte d\'Ivoire',
                    'Liste officielle des pharmacies autorisées et de garde.',
                  ),
                  const SizedBox(height: 12),
                  _buildSourceItem(
                    context,
                    'Ministère de la Santé',
                    'Données validées par les autorités sanitaires.',
                  ),
                  const SizedBox(height: 12),
                  _buildSourceItem(
                    context,
                    'Pharmacies partenaires',
                    'Informations mises à jour directement par les pharmacies.',
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: AppSpacing.paddingLg,
                    decoration: AppDecorations.accentCard(context, context.primary),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Nous nous efforçons de maintenir ces informations à jour. En cas de doute, contactez directement la pharmacie.',
                            style: TextStyles.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Contact support
            _buildSection(
              title: 'Contact support',
              icon: Icons.support_agent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Besoin d\'aide ? Notre équipe est là pour vous.',
                    style: TextStyles.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  _buildContactCard(
                    context,
                    icon: Icons.email,
                    title: 'Email',
                    value: 'support@pharmaciedegarde.ci',
                    onTap: () async {
                      final uri = Uri.parse('mailto:support@pharmaciedegarde.ci');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildContactCard(
                    context,
                    icon: Icons.phone,
                    title: 'Téléphone',
                    value: '+225 XX XX XX XX XX',
                    onTap: () async {
                      final uri = Uri.parse('tel:+225XXXXXXXXX');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildContactCard(
                    context,
                    icon: Icons.language,
                    title: 'Site web',
                    value: 'www.pharmaciedegarde.ci',
                    onTap: () async {
                      final uri = Uri.parse('https://www.pharmaciedegarde.ci');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildContactCard(
                    context,
                    icon: Icons.access_time,
                    title: 'Horaires',
                    value: 'Lun-Ven: 8h-18h',
                    onTap: null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Footer
            Center(
              child: Text(
                '© 2024 Pharmacie de Garde. Tous droits réservés.',
                style: TextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyles.titleLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildMissionItem(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyles.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSourceItem(
    BuildContext context,
    String title,
    String description,
  ) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingLg,
      decoration: AppDecorations.cardDecorationFlat(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyles.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return SurfaceCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 0),
      child: Row(
            children: [
              IconChip(icon: icon),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyles.labelLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyles.bodyLarge.copyWith(
                        color: onTap != null
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        decoration: onTap != null
                            ? TextDecoration.underline
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: context.textTertiary,
                ),
            ],
          ),
    );
  }
}

