import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/themes/colors.dart';
import '../../../../shared/styles/text_styles.dart';
import '../../../../shared/extensions/context_extensions.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'Français';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section Notifications
          _buildSectionHeader('Notifications'),
          _buildSettingsCard(
            children: [
              _buildSwitchTile(
                title: 'Notifications push',
                subtitle: 'Recevoir des notifications pour les pharmacies de garde',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
                icon: Icons.notifications_outlined,
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                title: 'Alertes d\'urgence',
                subtitle: 'Notifications pour les numéros d\'urgence',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
                icon: Icons.warning_amber_outlined,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Section Localisation
          _buildSectionHeader('Localisation'),
          _buildSettingsCard(
            children: [
              _buildSwitchTile(
                title: 'Géolocalisation automatique',
                subtitle: 'Utiliser votre position pour trouver les pharmacies proches',
                value: _locationEnabled,
                onChanged: (value) {
                  setState(() {
                    _locationEnabled = value;
                  });
                },
                icon: Icons.location_on_outlined,
              ),
              const Divider(height: 1),
              _buildListTile(
                title: 'Précision de localisation',
                subtitle: 'Haute précision',
                icon: Icons.my_location_outlined,
                onTap: () {
                  _showPrecisionDialog();
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Section Apparence
          _buildSectionHeader('Apparence'),
          _buildSettingsCard(
            children: [
              _buildSwitchTile(
                title: 'Mode sombre',
                subtitle: 'Activer le mode sombre automatique après 18h',
                value: _darkModeEnabled,
                onChanged: (value) {
                  setState(() {
                    _darkModeEnabled = value;
                  });
                },
                icon: Icons.dark_mode_outlined,
              ),
              const Divider(height: 1),
              _buildListTile(
                title: 'Langue',
                subtitle: _selectedLanguage,
                icon: Icons.language_outlined,
                onTap: () {
                  _showLanguageDialog();
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Section Données
          _buildSectionHeader('Données'),
          _buildSettingsCard(
            children: [
              _buildListTile(
                title: 'Effacer le cache',
                subtitle: 'Supprimer les données mises en cache',
                icon: Icons.delete_outline,
                onTap: () {
                  _showClearCacheDialog();
                },
              ),
              const Divider(height: 1),
              _buildListTile(
                title: 'Télécharger les données',
                subtitle: 'Mettre à jour la liste des pharmacies',
                icon: Icons.download_outlined,
                onTap: () {
                  _refreshData();
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Section Informations
          _buildSectionHeader('Informations'),
          _buildSettingsCard(
            children: [
              _buildListTile(
                title: 'Version de l\'application',
                subtitle: '1.0.0',
                icon: Icons.info_outline,
                onTap: null,
              ),
              const Divider(height: 1),
              _buildListTile(
                title: 'Politique de confidentialité',
                subtitle: 'Consulter notre politique',
                icon: Icons.privacy_tip_outlined,
                onTap: () {
                  _showPrivacyPolicy();
                },
              ),
              const Divider(height: 1),
              _buildListTile(
                title: 'Conditions d\'utilisation',
                subtitle: 'Lire les conditions',
                icon: Icons.description_outlined,
                onTap: () {
                  _showTermsOfService();
                },
              ),
            ],
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

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
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
        children: children,
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildListTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: onTap != null
          ? const Icon(Icons.chevron_right, color: AppColors.textSecondary)
          : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  void _showPrecisionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Précision de localisation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Haute précision'),
              subtitle: const Text('Utilise GPS, WiFi et réseaux mobiles'),
              value: 'high',
              groupValue: 'high',
              onChanged: (value) {
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Économie d\'énergie'),
              subtitle: const Text('Utilise WiFi et réseaux mobiles uniquement'),
              value: 'low',
              groupValue: 'high',
              onChanged: (value) {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Sélectionner la langue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Français'),
              value: 'Français',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'English',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Effacer le cache'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer toutes les données mises en cache ? '
          'Cela peut affecter les performances hors ligne.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.showSnackBar('Cache effacé avec succès');
            },
            child: const Text(
              'Effacer',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _refreshData() {
    context.showSnackBar('Mise à jour des données en cours...');
    // TODO: Implémenter la mise à jour des données
  }

  void _showPrivacyPolicy() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PrivacyPolicyPage(),
      ),
    );
  }

  void _showTermsOfService() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TermsOfServicePage(),
      ),
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Politique de confidentialité'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Politique de Confidentialité',
              style: TextStyles.displaySmall,
            ),
            const SizedBox(height: 24),
            Text(
              'Dernière mise à jour : ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: TextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '1. Collecte des données',
              content:
                  'Nous collectons uniquement les données nécessaires au fonctionnement de l\'application :\n\n'
                  '• Numéro de téléphone pour l\'authentification\n'
                  '• Position géographique pour localiser les pharmacies proches\n'
                  '• Données de navigation anonymisées pour améliorer le service',
            ),
            _buildSection(
              title: '2. Utilisation des données',
              content:
                  'Vos données sont utilisées exclusivement pour :\n\n'
                  '• Vous connecter à votre compte\n'
                  '• Trouver les pharmacies de garde les plus proches\n'
                  '• Améliorer l\'expérience utilisateur',
            ),
            _buildSection(
              title: '3. Protection des données',
              content:
                  'Nous mettons en œuvre des mesures de sécurité appropriées pour protéger vos données personnelles contre tout accès non autorisé, altération, divulgation ou destruction.',
            ),
            _buildSection(
              title: '4. Partage des données',
              content:
                  'Nous ne vendons, n\'échangeons ni ne louons vos données personnelles à des tiers. Vos données peuvent être partagées uniquement dans les cas suivants :\n\n'
                  '• Avec votre consentement explicite\n'
                  '• Pour répondre à une obligation légale\n'
                  '• Pour protéger nos droits et notre sécurité',
            ),
            _buildSection(
              title: '5. Vos droits',
              content:
                  'Vous avez le droit de :\n\n'
                  '• Accéder à vos données personnelles\n'
                  '• Demander la correction de vos données\n'
                  '• Demander la suppression de vos données\n'
                  '• Vous opposer au traitement de vos données',
            ),
            _buildSection(
              title: '6. Contact',
              content:
                  'Pour toute question concernant cette politique de confidentialité, veuillez nous contacter à :\n\n'
                  'support@pharmaciedegarde.ci',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Conditions d\'utilisation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Conditions d\'Utilisation',
              style: TextStyles.displaySmall,
            ),
            const SizedBox(height: 24),
            Text(
              'Dernière mise à jour : ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: TextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '1. Acceptation des conditions',
              content:
                  'En utilisant cette application, vous acceptez d\'être lié par ces conditions d\'utilisation. Si vous n\'acceptez pas ces conditions, veuillez ne pas utiliser l\'application.',
            ),
            _buildSection(
              title: '2. Description du service',
              content:
                  'Cette application vous permet de :\n\n'
                  '• Trouver les pharmacies de garde les plus proches\n'
                  '• Accéder aux numéros d\'urgence\n'
                  '• Obtenir des informations sur les pharmacies\n'
                  '• Contacter directement les pharmacies',
            ),
            _buildSection(
              title: '3. Utilisation de l\'application',
              content:
                  'Vous vous engagez à utiliser l\'application de manière légale et responsable. Il est interdit de :\n\n'
                  '• Utiliser l\'application à des fins illégales\n'
                  '• Tenter d\'accéder à des zones non autorisées\n'
                  '• Perturber le fonctionnement de l\'application\n'
                  '• Copier ou reproduire le contenu sans autorisation',
            ),
            _buildSection(
              title: '4. Exactitude des informations',
              content:
                  'Nous nous efforçons de fournir des informations exactes et à jour. Cependant, nous ne garantissons pas l\'exactitude, l\'exhaustivité ou l\'actualité des informations fournies.',
            ),
            _buildSection(
              title: '5. Limitation de responsabilité',
              content:
                  'L\'application est fournie "en l\'état". Nous ne sommes pas responsables des dommages directs, indirects, accessoires ou consécutifs résultant de l\'utilisation ou de l\'impossibilité d\'utiliser l\'application.',
            ),
            _buildSection(
              title: '6. Modifications',
              content:
                  'Nous nous réservons le droit de modifier ces conditions à tout moment. Les modifications entreront en vigueur dès leur publication dans l\'application.',
            ),
            _buildSection(
              title: '7. Contact',
              content:
                  'Pour toute question concernant ces conditions d\'utilisation, veuillez nous contacter à :\n\n'
                  'support@pharmaciedegarde.ci',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}

