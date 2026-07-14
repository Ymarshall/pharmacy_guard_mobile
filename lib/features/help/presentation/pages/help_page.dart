import 'package:flutter/material.dart';
import '../../../../config/themes/colors.dart';
import '../../../../shared/styles/text_styles.dart';
import '../../../../shared/extensions/context_extensions.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Aide'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section Comment utiliser
          _buildSectionHeader('Comment utiliser l\'application'),
          _buildHelpCard(
            icon: Icons.search_outlined,
            title: 'Rechercher une pharmacie',
            description:
                'Utilisez la barre de recherche en haut de l\'écran d\'accueil pour rechercher une pharmacie par son nom, sa ville, sa commune ou son adresse. Les résultats sont automatiquement triés par proximité.',
            onTap: () {
              _showSearchHelp(context);
            },
          ),
          const SizedBox(height: 12),
          _buildHelpCard(
            icon: Icons.location_on_outlined,
            title: 'Trouver les pharmacies proches',
            description:
                'L\'application utilise votre position pour afficher les pharmacies de garde les plus proches. Assurez-vous que la géolocalisation est activée dans les paramètres.',
            onTap: () {
              _showLocationHelp(context);
            },
          ),
          const SizedBox(height: 12),
          _buildHelpCard(
            icon: Icons.phone_outlined,
            title: 'Contacter une pharmacie',
            description:
                'Appuyez sur le bouton "Appeler" sur la carte d\'une pharmacie pour l\'appeler directement. Vous pouvez également utiliser le bouton "Itinéraire" pour ouvrir Google Maps.',
            onTap: () {
              _showContactHelp(context);
            },
          ),
          const SizedBox(height: 12),
          _buildHelpCard(
            icon: Icons.emergency_outlined,
            title: 'Numéros d\'urgence',
            description:
                'Le bouton flottant "Numéros utiles" vous donne accès aux numéros d\'urgence (SAMU, Pompiers, Police, etc.). Appuyez sur un numéro pour appeler directement.',
            onTap: () {
              _showEmergencyHelp(context);
            },
          ),
          const SizedBox(height: 24),

          // Section FAQ
          _buildSectionHeader('Questions fréquentes'),
          _buildFAQCard(
            question: 'Comment fonctionne la géolocalisation ?',
            answer:
                'L\'application utilise votre position GPS pour trouver les pharmacies les plus proches. Si la géolocalisation n\'est pas disponible, nous utilisons la position enregistrée lors de votre inscription.',
          ),
          const SizedBox(height: 12),
          _buildFAQCard(
            question: 'Les pharmacies sont-elles toujours ouvertes ?',
            answer:
                'Non, les pharmacies de garde sont ouvertes selon un planning spécifique. L\'application affiche le statut de chaque pharmacie (ouverte, fermée, de garde) en temps réel.',
          ),
          const SizedBox(height: 12),
          _buildFAQCard(
            question: 'Puis-je utiliser l\'application hors ligne ?',
            answer:
                'Oui, l\'application sauvegarde automatiquement les données en local. Vous pouvez consulter les pharmacies récemment chargées même sans connexion internet.',
          ),
          const SizedBox(height: 12),
          _buildFAQCard(
            question: 'Comment mettre à jour les données ?',
            answer:
                'Les données sont automatiquement mises à jour lorsque vous êtes connecté à internet. Vous pouvez également forcer une mise à jour depuis les paramètres.',
          ),
          const SizedBox(height: 12),
          _buildFAQCard(
            question: 'L\'application est-elle gratuite ?',
            answer:
                'Oui, l\'application est entièrement gratuite. Aucun frais n\'est facturé pour l\'utilisation du service.',
          ),
          const SizedBox(height: 24),

          // Section Contact
          _buildSectionHeader('Besoin d\'aide ?'),
          _buildContactCard(
            icon: Icons.email_outlined,
            title: 'Email',
            subtitle: 'support@pharmaciedegarde.ci',
            onTap: () {
              _openEmail(context);
            },
          ),
          const SizedBox(height: 12),
          _buildContactCard(
            icon: Icons.phone_outlined,
            title: 'Téléphone',
            subtitle: '+225 27 22 44 55 66',
            onTap: () {
              _makePhoneCall(context);
            },
          ),
          const SizedBox(height: 12),
          _buildContactCard(
            icon: Icons.chat_bubble_outline,
            title: 'Chat en direct',
            subtitle: 'Disponible du lundi au vendredi, 8h-18h',
            onTap: () {
              _openChat(context);
            },
          ),
          const SizedBox(height: 24),

          // Section À propos
          _buildSectionHeader('À propos'),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.local_pharmacy,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pharmacie de Garde',
                            style: TextStyles.titleLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Version 1.0.0',
                            style: TextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Notre mission',
                  style: TextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Faciliter l\'accès aux soins de santé en vous aidant à trouver rapidement les pharmacies de garde les plus proches, 24h/24 et 7j/7.',
                  style: TextStyles.bodyMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  'Sources de données',
                  style: TextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Les informations sur les pharmacies proviennent de sources officielles et sont mises à jour régulièrement pour garantir leur exactitude.',
                  style: TextStyles.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: TextStyles.titleMedium.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildHelpCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQCard({
    required String question,
    required String answer,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.help_outline,
                  color: AppColors.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question,
                  style: TextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Text(
              answer,
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Rechercher une pharmacie'),
        content: const Text(
          'La barre de recherche vous permet de rechercher une pharmacie par :\n\n'
          '• Son nom\n'
          '• Sa ville\n'
          '• Sa commune\n'
          '• Son district\n'
          '• Son adresse complète\n'
          '• Le nom du pharmacien\n'
          '• Son numéro de téléphone\n\n'
          'Les résultats sont automatiquement triés par proximité.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  void _showLocationHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Géolocalisation'),
        content: const Text(
          'Pour trouver les pharmacies les plus proches, l\'application a besoin d\'accéder à votre position.\n\n'
          'Vous pouvez activer ou désactiver la géolocalisation depuis les paramètres de l\'application.\n\n'
          'Si la géolocalisation est désactivée, nous utilisons la position enregistrée lors de votre inscription.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  void _showContactHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Contacter une pharmacie'),
        content: const Text(
          'Pour contacter une pharmacie :\n\n'
          '1. Appuyez sur le bouton "Appeler" pour l\'appeler directement\n'
          '2. Appuyez sur le bouton "Itinéraire" pour ouvrir Google Maps et obtenir les directions\n'
          '3. Appuyez sur la carte de la pharmacie pour voir plus de détails',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  void _showEmergencyHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Numéros d\'urgence'),
        content: const Text(
          'Le bouton flottant "Numéros utiles" vous donne accès à tous les numéros d\'urgence :\n\n'
          '• SAMU\n'
          '• Pompiers\n'
          '• Police\n'
          '• Banque de sang\n'
          '• Et autres services d\'urgence\n\n'
          'Appuyez sur un numéro pour appeler directement.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  void _openEmail(BuildContext context) {
    // TODO: Implémenter l'ouverture de l'application email
    context.showSnackBar('Ouverture de l\'application email...');
  }

  void _makePhoneCall(BuildContext context) {
    // TODO: Implémenter l'appel téléphonique
    context.showSnackBar('Appel en cours...');
  }

  void _openChat(BuildContext context) {
    // TODO: Implémenter le chat en direct
    context.showSnackBar('Ouverture du chat...');
  }
}

