import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/themes/colors.dart';
import '../../../../shared/styles/text_styles.dart';
import '../../../../shared/extensions/context_extensions.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('À propos'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo/Header
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                    child: const Icon(
                      Icons.local_pharmacy,
                      size: 50,
                      color: AppColors.primary,
                    ),
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
                    'Ordre National des Pharmaciens de Côte d\'Ivoire',
                    'Liste officielle des pharmacies autorisées et de garde.',
                  ),
                  const SizedBox(height: 12),
                  _buildSourceItem(
                    'Ministère de la Santé',
                    'Données validées par les autorités sanitaires.',
                  ),
                  const SizedBox(height: 12),
                  _buildSourceItem(
                    'Pharmacies partenaires',
                    'Informations mises à jour directement par les pharmacies.',
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
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
            Text(
              title,
              style: TextStyles.titleLarge.copyWith(
                color: AppColors.primary,
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

  Widget _buildSourceItem(String title, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
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

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                ),
              ),
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
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

