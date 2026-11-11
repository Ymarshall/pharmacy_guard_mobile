import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/surface_card.dart';
import '../../domain/entities/pharmacy.dart';
import '../../../../core/utils/distance_utils.dart';

class PharmacyCard extends StatefulWidget {
  final Pharmacy pharmacy;
  final VoidCallback? onTap;
  final double? userLatitude;
  final double? userLongitude;

  const PharmacyCard({
    super.key,
    required this.pharmacy,
    this.onTap,
    this.userLatitude,
    this.userLongitude,
  });

  @override
  State<PharmacyCard> createState() => _PharmacyCardState();
}

class _PharmacyCardState extends State<PharmacyCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    // Animation pulsante pour le badge de statut si ouvert
    if (widget.pharmacy.isOpen || widget.pharmacy.isOnDuty) {
      _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 2),
      )..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    if (widget.pharmacy.isOpen || widget.pharmacy.isOnDuty) {
      _pulseController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: SurfaceCard(
          margin: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          padding: AppSpacing.paddingLg,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.pharmacy.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: context.onSurface,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildStatusBadge(),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: context.textTertiary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getAddress(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: context.textSecondary,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Travel time and status
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildStatusChip(),
                    if (widget.pharmacy.distance != null) ...[
                      _buildTimeChip(
                        icon: Icons.directions_car_outlined,
                        text: DistanceUtils.formatDrivingTime(widget.pharmacy.distance!),
                        color: AppColors.primary,
                      ),
                      _buildTimeChip(
                        icon: Icons.directions_walk_outlined,
                        text: DistanceUtils.formatWalkingTime(widget.pharmacy.distance!),
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.phone_outlined,
                        label: 'Appeler',
                        isPrimary: true,
                        onPressed: () async {
                          final uri = Uri.parse('tel:${widget.pharmacy.phone1}');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.platformDefault);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.directions_outlined,
                        label: 'Itinéraire',
                        isPrimary: false,
                        onPressed: () async {
                          // Utiliser la position de l'utilisateur si disponible, sinon juste afficher la pharmacie
                          if (widget.userLatitude != null && widget.userLongitude != null) {
                            // Tracer l'itinéraire depuis la position de l'utilisateur vers la pharmacie
                            // Utiliser l'URL web qui fonctionne sur tous les appareils et émulateurs
                            final uri = Uri.parse(
                              'https://www.google.com/maps/dir/?api=1&origin=${widget.userLatitude},${widget.userLongitude}&destination=${widget.pharmacy.latitude},${widget.pharmacy.longitude}&travelmode=driving',
                            );
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            } else {
                              // Fallback : essayer avec le schéma Android si l'URL web ne fonctionne pas
                              if (Platform.isAndroid) {
                                try {
                                  final androidUri = Uri.parse(
                                    'google.navigation:q=${widget.pharmacy.latitude},${widget.pharmacy.longitude}',
                                  );
                                  if (await canLaunchUrl(androidUri)) {
                                    await launchUrl(androidUri, mode: LaunchMode.externalApplication);
                                  }
                                } catch (e) {
                                  // Si ça échoue aussi, utiliser geo: comme dernier recours
                                  final geoUri = Uri.parse(
                                    'geo:${widget.pharmacy.latitude},${widget.pharmacy.longitude}?q=${widget.pharmacy.latitude},${widget.pharmacy.longitude}',
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
                              'https://www.google.com/maps/search/?api=1&query=${widget.pharmacy.latitude},${widget.pharmacy.longitude}',
                            );
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            } else {
                              // Fallback pour Android
                              if (Platform.isAndroid) {
                                try {
                                  final geoUri = Uri.parse(
                                    'geo:${widget.pharmacy.latitude},${widget.pharmacy.longitude}?q=${widget.pharmacy.latitude},${widget.pharmacy.longitude}',
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
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color badgeColor;
    String badgeText;
    IconData badgeIcon;

    if (widget.pharmacy.isOnDuty) {
      badgeColor = AppColors.pharmacyOnDuty;
      badgeText = 'De garde';
      badgeIcon = Icons.local_pharmacy_outlined;
    } else if (widget.pharmacy.isOpen) {
      badgeColor = AppColors.pharmacyOpen;
      badgeText = 'Ouverte';
      badgeIcon = Icons.check_circle_outline;
    } else {
      badgeColor = AppColors.pharmacyClosed;
      badgeText = 'Fermée';
      badgeIcon = Icons.cancel_outlined;
    }

    final Widget badge = StatusBadge(
      label: badgeText,
      icon: badgeIcon,
      color: badgeColor.withValues(alpha: 0.12),
      textColor: badgeColor,
    );

    // Animation pulsante pour les pharmacies ouvertes
    if ((widget.pharmacy.isOpen || widget.pharmacy.isOnDuty) &&
        widget.pharmacy.isOnDuty) {
      return AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Opacity(
            opacity: 0.8 + (_pulseController.value * 0.2),
            child: badge,
          );
        },
      );
    }

    return badge;
  }

  Widget _buildStatusChip() {
    Color chipColor;
    String chipText;
    IconData chipIcon;

    if (widget.pharmacy.isOnDuty) {
      chipColor = AppColors.pharmacyOnDuty;
      chipText = 'De garde';
      chipIcon = Icons.local_pharmacy_outlined;
    } else if (widget.pharmacy.isOpen) {
      chipColor = AppColors.pharmacyOpen;
      chipText = 'Ouverte';
      chipIcon = Icons.check_circle_outline;
    } else {
      chipColor = AppColors.pharmacyClosed;
      chipText = 'Fermée';
      chipIcon = Icons.cancel_outlined;
    }

    return StatusBadge(
      label: chipText,
      icon: chipIcon,
      color: chipColor.withValues(alpha: 0.12),
      textColor: chipColor,
    );
  }

  Widget _buildTimeChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.surfaceSubtle,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  String _getAddress() {
    final parts = <String>[];
    if (widget.pharmacy.commune != null && widget.pharmacy.commune!.isNotEmpty) {
      parts.add(widget.pharmacy.commune!);
    }
    if (widget.pharmacy.city != null && widget.pharmacy.city!.isNotEmpty) {
      parts.add(widget.pharmacy.city!);
    }
    if (widget.pharmacy.district != null && widget.pharmacy.district!.isNotEmpty) {
      parts.add(widget.pharmacy.district!);
    }
    return parts.isNotEmpty ? parts.join(', ') : 'Adresse non disponible';
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    if (isPrimary) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: context.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.controlRadius),
          ),
        ),
      );
    } else {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18, color: context.primary),
        label: Text(
          label,
          style: TextStyle(color: context.primary),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: context.primary,
          side: BorderSide(color: context.primary, width: 1.2),
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.controlRadius),
          ),
        ),
      );
    }
  }
}
