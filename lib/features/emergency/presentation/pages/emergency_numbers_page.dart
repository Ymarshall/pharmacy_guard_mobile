import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/themes/colors.dart';
import '../../../../shared/styles/text_styles.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../core/utils/icon_utils.dart';
import '../../domain/entities/emergency_number.dart';
import '../providers/emergency_notifier.dart';

class EmergencyNumbersPage extends ConsumerStatefulWidget {
  const EmergencyNumbersPage({super.key});

  @override
  ConsumerState<EmergencyNumbersPage> createState() => _EmergencyNumbersPageState();
}

class _EmergencyNumbersPageState extends ConsumerState<EmergencyNumbersPage> {
  @override
  void initState() {
    super.initState();
    // Charger les numéros d'urgence au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(emergencyNotifierProvider.notifier).getEmergencyNumbers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final emergencyState = ref.watch(emergencyNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Numéros d\'Urgence'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.error,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: _buildBody(emergencyState),
    );
  }

  Widget _buildBody(EmergencyState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.error,
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              state.error!,
              style: TextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(emergencyNotifierProvider.notifier).getEmergencyNumbers();
              },
              child: const Text('Réessayer'),
            ),
            if (state.error!.contains('cache') || state.error!.contains('connexion'))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Mode hors ligne : Affichage des dernières données mises en cache',
                  style: TextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      );
    }

    final emergencyNumbers = state.emergencyNumbers;

    if (emergencyNumbers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.emergency_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun numéro d\'urgence disponible',
              style: TextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Grouper par catégorie
    final medicalNumbers = emergencyNumbers
        .where((n) => n.category == EmergencyCategory.medical)
        .toList();
    final fireNumbers = emergencyNumbers
        .where((n) => n.category == EmergencyCategory.fire)
        .toList();
    final policeNumbers = emergencyNumbers
        .where((n) => n.category == EmergencyCategory.police)
        .toList();
    final bloodBankNumbers = emergencyNumbers
        .where((n) => n.category == EmergencyCategory.bloodBank)
        .toList();
    final otherNumbers = emergencyNumbers
        .where((n) => n.category == EmergencyCategory.other)
        .toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emergency,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Numéros d\'Urgence',
                  style: TextStyles.displaySmall.copyWith(
                    color: AppColors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Composez ces numéros en cas d\'urgence',
                  style: TextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                if (state.isFromCache)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.cloud_off, size: 16, color: AppColors.warning),
                          const SizedBox(width: 6),
                          Text(
                            'Mode hors ligne',
                            style: TextStyles.bodySmall.copyWith(
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Medical section
          if (medicalNumbers.isNotEmpty)
            _buildCategorySection(
              context,
              title: 'Médical',
              icon: Icons.local_hospital,
              color: AppColors.error,
              numbers: medicalNumbers,
            ),
          // Fire section
          if (fireNumbers.isNotEmpty)
            _buildCategorySection(
              context,
              title: 'Pompiers',
              icon: Icons.fire_extinguisher,
              color: Colors.orange,
              numbers: fireNumbers,
            ),
          // Police section
          if (policeNumbers.isNotEmpty)
            _buildCategorySection(
              context,
              title: 'Police',
              icon: Icons.local_police,
              color: Colors.blue,
              numbers: policeNumbers,
            ),
          // Blood Bank section
          if (bloodBankNumbers.isNotEmpty)
            _buildCategorySection(
              context,
              title: 'Banque de Sang',
              icon: Icons.bloodtype,
              color: Colors.red,
              numbers: bloodBankNumbers,
            ),
          // Other section
          if (otherNumbers.isNotEmpty)
            _buildCategorySection(
              context,
              title: 'Autres',
              icon: Icons.info,
              color: AppColors.textSecondary,
              numbers: otherNumbers,
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<EmergencyNumber> numbers,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyles.titleLarge.copyWith(
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...numbers.map((number) => _buildEmergencyCard(context, number)),
        ],
      ),
    );
  }

  Widget _buildEmergencyCard(BuildContext context, EmergencyNumber number) {
    final iconColor = IconUtils.hexToColor(number.color);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () async {
          final uri = Uri.parse('tel:${number.number}');
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.platformDefault);
          } else {
            if (context.mounted) {
              context.showSnackBar('Impossible d\'ouvrir le composeur téléphonique');
            }
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    IconUtils.getIcon(number.icon),
                    color: iconColor,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      number.name,
                      style: TextStyles.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      number.description,
                      style: TextStyles.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          number.number,
                          style: TextStyles.bodyLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Call button
              IconButton(
                onPressed: () async {
                  final uri = Uri.parse('tel:${number.number}');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.platformDefault);
                  } else {
                    if (context.mounted) {
                      context.showSnackBar('Impossible d\'ouvrir le composeur téléphonique');
                    }
                  }
                },
                icon: const Icon(
                  Icons.phone,
                  color: AppColors.primary,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
