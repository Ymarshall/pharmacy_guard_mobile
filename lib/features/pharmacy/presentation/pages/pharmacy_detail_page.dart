import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_decorations.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/icon_chip.dart';
import '../../../../shared/widgets/screen_app_bar.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../core/utils/distance_utils.dart';
import '../../domain/entities/pharmacy.dart';
import '../../domain/entities/insurance.dart';
import '../../../review/presentation/widgets/reviews_section_widget.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../../core/providers/providers.dart' as providers;

class PharmacyDetailPage extends ConsumerWidget {
  final Pharmacy pharmacy;
  final double? userLatitude;
  final double? userLongitude;

  const PharmacyDetailPage({
    super.key,
    required this.pharmacy,
    this.userLatitude,
    this.userLongitude,
  });

  String _getAddress() {
    final parts = <String>[];
    if (pharmacy.commune != null && pharmacy.commune!.isNotEmpty) {
      parts.add(pharmacy.commune!);
    }
    if (pharmacy.city != null && pharmacy.city!.isNotEmpty) {
      parts.add(pharmacy.city!);
    }
    if (pharmacy.district != null && pharmacy.district!.isNotEmpty) {
      parts.add(pharmacy.district!);
    }
    return parts.isNotEmpty ? parts.join(', ') : 'Adresse non disponible';
  }

  double? _getCalculatedDistance() {
    if (userLatitude != null && userLongitude != null) {
      return DistanceUtils.calculateDistance(
        userLatitude!,
        userLongitude!,
        pharmacy.latitude,
        pharmacy.longitude,
      );
    }
    return pharmacy.distance;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calculatedDistance = _getCalculatedDistance();
    final authState = ref.watch(authNotifierProvider);
    final clientId = authState.authResponse?.client.id ?? 0;
    
    return Scaffold(
      backgroundColor: context.background,
      appBar: const ScreenAppBar(title: 'Détails de la pharmacie'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo de la façade
            if (pharmacy.photo != null && pharmacy.photo!.isNotEmpty) _buildPhotoSection(),
            _buildHeader(),
            _buildInfoSection(calculatedDistance),
            if (pharmacy.assurances.isNotEmpty) _buildInsurancesSection(),
            if (pharmacy.horaires != null && pharmacy.horaires!.isNotEmpty) _buildHorairesSection(),
            _buildActionButtons(context, ref, clientId),
            // Section des commentaires
            if (clientId > 0) ...[
              const SizedBox(height: 24),
              ReviewsSectionWidget(
                pharmacyId: int.tryParse(pharmacy.id) ?? 0,
                clientId: clientId,
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: AppColors.background,
      ),
      child: Image.network(
        pharmacy.photo!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppColors.primarySurface,
            child: const Icon(
              Icons.local_pharmacy_outlined,
              size: 64,
              color: AppColors.primary,
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const IconChip(
                icon: Icons.local_pharmacy_outlined,
                size: 56,
                iconSize: 28,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                pharmacy.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: context.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildStatusBadge(),
              if (pharmacy.averageRating != null) ...[
                const SizedBox(height: AppSpacing.md),
                _buildRatingDisplay(pharmacy.averageRating!),
              ],
              if (pharmacy.description != null &&
                  pharmacy.description!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  pharmacy.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.textSecondary,
                      ),
                ),
              ],
              if (pharmacy.pharmacistName != null &&
                  pharmacy.pharmacistName!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Pharmacien : ${pharmacy.pharmacistName}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.textTertiary,
                      ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge() {
    Color badgeColor;
    String badgeText;

    if (pharmacy.isOnDuty) {
      badgeColor = AppColors.pharmacyOnDuty;
      badgeText = 'De garde';
    } else if (pharmacy.isOpen) {
      badgeColor = AppColors.pharmacyOpen;
      badgeText = 'Ouverte';
    } else {
      badgeColor = AppColors.pharmacyClosed;
      badgeText = 'Fermée';
    }

    return StatusBadge(
      label: badgeText,
      color: badgeColor.withValues(alpha: 0.12),
      textColor: badgeColor,
    );
  }

  Widget _buildRatingDisplay(double rating) {
    // Clamp rating between 0 and 5
    final clampedRating = rating.clamp(0.0, 5.0);
    final fullStars = clampedRating.floor();
    final hasHalfStar = (clampedRating - fullStars) >= 0.5;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Étoiles pleines
        ...List.generate(fullStars, (index) => Icon(
          Icons.star,
          color: AppColors.accent,
          size: 20,
        )),
        // Demi-étoile si nécessaire
        if (hasHalfStar)
          Icon(
            Icons.star_half,
            color: AppColors.accent,
            size: 20,
          ),
        // Étoiles vides
        ...List.generate(5 - fullStars - (hasHalfStar ? 1 : 0), (index) => Icon(
          Icons.star_border,
          color: AppColors.textTertiary,
          size: 20,
        )),
        const SizedBox(width: 8),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 4),
        const Text(
          '/ 5.0',
          style: TextStyle(fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildInfoSection(double? distance) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoItem(
            icon: Icons.location_on,
            title: 'Adresse',
            value: _getAddress(),
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            icon: Icons.phone,
            title: 'Téléphone',
            value: pharmacy.phone1,
            isClickable: true,
            onTap: () async {
              final uri = Uri.parse('tel:${pharmacy.phone1}');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.platformDefault);
              }
            },
          ),
          if (pharmacy.phone2 != null && pharmacy.phone2!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoItem(
              icon: Icons.phone,
              title: 'Téléphone 2',
              value: pharmacy.phone2!,
              isClickable: true,
              onTap: () async {
                final uri = Uri.parse('tel:${pharmacy.phone2}');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.platformDefault);
                }
              },
            ),
          ],
          if (pharmacy.email != null && pharmacy.email!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoItem(
              icon: Icons.email,
              title: 'Email',
              value: pharmacy.email!,
              isClickable: true,
              onTap: () async {
                final uri = Uri.parse('mailto:${pharmacy.email}');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.platformDefault);
                }
              },
            ),
          ],
          if (distance != null) ...[
            const SizedBox(height: 16),
            _buildDistanceInfo(distance),
          ],
        ],
      ),
    );
  }

  Widget _buildDistanceInfo(double distance) {
    return Builder(
      builder: (context) {
        return Container(
          padding: AppSpacing.paddingLg,
          decoration: AppDecorations.cardDecoration(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Distance et temps de trajet',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Icon(Icons.straighten, color: context.primary, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    DistanceUtils.formatDistance(distance),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: context.onSurface,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Icon(
                    Icons.directions_walk_outlined,
                    color: context.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${DistanceUtils.formatWalkingTime(distance)} à pied',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(
                    Icons.directions_car_outlined,
                    color: context.primary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${DistanceUtils.formatDrivingTime(distance)} en voiture',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHorairesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Horaires'),
          const SizedBox(height: AppSpacing.md),
          Builder(
            builder: (context) => Container(
              width: double.infinity,
              padding: AppSpacing.paddingLg,
              decoration: AppDecorations.cardDecoration(context),
              child: Text(
                pharmacy.horaires!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsurancesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Assurances autorisées'),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: pharmacy.assurances.map((insurance) {
              return Chip(
                label: Text(insurance.name),
                backgroundColor: AppColors.primarySurface,
                side: BorderSide.none,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    bool isClickable = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: isClickable ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      color: isClickable ? AppColors.primary : null,
                      decoration:
                          isClickable ? TextDecoration.underline : null,
                    ),
                  ),
                ],
              ),
            ),
            if (isClickable)
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, int clientId) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final uri = Uri.parse('tel:${pharmacy.phone1}');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.platformDefault);
                }
              },
              icon: const Icon(Icons.phone),
              label: const Text('Appeler'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                // Utiliser la position de l'utilisateur si disponible, sinon juste afficher la pharmacie
                if (userLatitude != null && userLongitude != null) {
                  // Tracer l'itinéraire depuis la position de l'utilisateur vers la pharmacie
                  // Utiliser l'URL web qui fonctionne sur tous les appareils et émulateurs
                  final uri = Uri.parse(
                    'https://www.google.com/maps/dir/?api=1&origin=$userLatitude,$userLongitude&destination=${pharmacy.latitude},${pharmacy.longitude}&travelmode=driving',
                  );
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    // Fallback : essayer avec le schéma Android si l'URL web ne fonctionne pas
                    if (Platform.isAndroid) {
                      try {
                        final androidUri = Uri.parse(
                          'google.navigation:q=${pharmacy.latitude},${pharmacy.longitude}',
                        );
                        if (await canLaunchUrl(androidUri)) {
                          await launchUrl(androidUri, mode: LaunchMode.externalApplication);
                        }
                      } catch (e) {
                        // Si ça échoue aussi, utiliser geo: comme dernier recours
                        final geoUri = Uri.parse(
                          'geo:${pharmacy.latitude},${pharmacy.longitude}?q=${pharmacy.latitude},${pharmacy.longitude}',
                        );
                        if (await canLaunchUrl(geoUri)) {
                          await launchUrl(geoUri, mode: LaunchMode.externalApplication);
                        }
                      }
                    }
                  }
                } else {
                  // Si pas de position utilisateur, juste afficher la pharmacie
                  final uri = Uri.parse(
                    'https://www.google.com/maps/search/?api=1&query=${pharmacy.latitude},${pharmacy.longitude}',
                  );
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    // Fallback pour Android
                    if (Platform.isAndroid) {
                      try {
                        final geoUri = Uri.parse(
                          'geo:${pharmacy.latitude},${pharmacy.longitude}?q=${pharmacy.latitude},${pharmacy.longitude}',
                        );
                        if (await canLaunchUrl(geoUri)) {
                          await launchUrl(geoUri, mode: LaunchMode.externalApplication);
                        }
                      } catch (e) {
                        // Ignorer l'erreur
                      }
                    }
                  }
                }
              },
              icon: const Icon(Icons.directions),
              label: const Text('Itinéraire'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary, width: 1.2),
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
          // Bouton de signalement (seulement si la pharmacie est marquée comme de garde)
          if (pharmacy.isOnDuty && clientId > 0) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showReportDialog(context, ref, clientId),
                icon: const Icon(Icons.report_problem_outlined),
                label: const Text('Signaler une erreur de garde'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error, width: 1.2),
                  foregroundColor: AppColors.error,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context, WidgetRef ref, int clientId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.report_problem, color: AppColors.error, size: 24),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Signaler une erreur de garde',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: const Text(
            'Cette pharmacie est indiquée comme étant de garde, mais elle ne l\'est pas réellement ? '
            'Signalez-le pour nous aider à maintenir des informations exactes.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _reportDutyIssue(context, ref, clientId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Signaler'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _reportDutyIssue(BuildContext context, WidgetRef ref, int clientId) async {
    try {
      final reportDataSource = ref.read(providers.pharmacyReportDataSourceProvider);
      final pharmacyId = int.tryParse(pharmacy.id) ?? 0;

      if (pharmacyId == 0) {
        if (context.mounted) {
          context.showErrorSnackBar('Impossible de signaler cette pharmacie');
        }
        return;
      }

      // Afficher un loader
      if (context.mounted) {
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
                      'Envoi du signalement...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }

      await reportDataSource.reportDutyIssue(
        pharmacyId: pharmacyId,
        clientId: clientId,
      );

      // Fermer le loader
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Afficher un message de succès
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.success, size: 24),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Signalement envoyé',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
              content: const Text(
                'Merci pour votre signalement. Nous allons vérifier cette information.',
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Fermer le loader en cas d'erreur
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Afficher un message d'erreur
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text('Erreur'),
              content: Text(
                'Erreur lors de l\'envoi du signalement: ${e.toString()}',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }
}
