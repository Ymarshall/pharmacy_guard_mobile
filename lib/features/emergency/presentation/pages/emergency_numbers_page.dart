import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/icon_chip.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/screen_app_bar.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/surface_card.dart';
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
      backgroundColor: context.background,
      appBar: const ScreenAppBar(title: 'Numéros d\'urgence'),
      body: _buildBody(emergencyState),
    );
  }

  Widget _buildBody(EmergencyState state) {
    if (state.isLoading) {
      return const LoadingWidget(message: 'Chargement des numéros...');
    }

    if (state.error != null) {
      return AppErrorWidget(
        title: 'Numéros indisponibles',
        message: state.error!,
        onRetry: () {
          ref.read(emergencyNotifierProvider.notifier).getEmergencyNumbers();
        },
      );
    }

    final emergencyNumbers = state.emergencyNumbers;

    if (emergencyNumbers.isEmpty) {
      return const EmptyState(
        icon: Icons.emergency_outlined,
        title: 'Aucun numéro',
        message: 'Aucun numéro d\'urgence disponible',
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
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconChip(
                  icon: Icons.emergency_outlined,
                  backgroundColor: context.errorSurface,
                  iconColor: context.error,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Composez ces numéros en cas d\'urgence',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: context.textSecondary,
                      ),
                ),
                if (state.isFromCache) ...[
                  const SizedBox(height: AppSpacing.md),
                  StatusBadge.warning('Mode hors ligne'),
                ],
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
              IconChip(
                icon: icon,
                size: 36,
                iconSize: 18,
                backgroundColor: color.withValues(alpha: 0.12),
                iconColor: color,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: SectionHeader(title: title)),
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
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: SurfaceCard(
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
        child: Row(
            children: [
              IconChip(
                icon: IconUtils.getIcon(number.icon),
                backgroundColor: iconColor.withValues(alpha: 0.12),
                iconColor: iconColor,
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      number.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      number.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.textTertiary,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      number.number,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: context.primary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: context.textTertiary),
            ],
          ),
      ),
    );
  }
}
