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
    return SurfaceCard(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.pharmacy.name,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.onSurface,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getAddress(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.textSecondary,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onTap,
                  child: Row(
                    children: [
                      _buildStatusBadge(),
                      if (widget.pharmacy.hasGps &&
                          widget.pharmacy.distance != null) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildDistanceLine(
                            context,
                            widget.pharmacy.distance!,
                          ),
                        ),
                      ] else if (!widget.pharmacy.hasGps) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Localisation indisponible',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: context.textTertiary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              _roundAction(
                icon: Icons.phone_outlined,
                label: 'Appeler',
                background: context.primarySurface,
                foreground: context.primary,
                onPressed: _callPharmacy,
              ),
              _roundAction(
                icon: Icons.directions_outlined,
                label:
                    widget.pharmacy.hasGps
                        ? 'Itinéraire'
                        : 'Localisation indisponible',
                background: context.surfaceSubtle,
                foreground: context.primary,
                onPressed: widget.pharmacy.hasGps ? _openDirections : null,
              ),
            ],
          ),
        ],
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

  Widget _buildDistanceLine(BuildContext context, double distance) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: context.textTertiary,
      fontSize: 12,
      height: 1.2,
    );
    final distanceLabel = _formatKm(distance);
    final drivingTime = DistanceUtils.formatDrivingTime(distance);
    final walkingTime = DistanceUtils.formatWalkingTime(distance);

    final driving = '$distanceLabel · $drivingTime';
    return LayoutBuilder(
      builder: (context, constraints) {
        // Le temps en voiture (estimé) reste toujours visible ; le temps à
        // pied n'apparaît que s'il reste de la place.
        final showWalking = fitsWalkingTime(
          driving: driving,
          walkingTime: walkingTime,
          maxWidth: constraints.maxWidth,
          style: style ?? const TextStyle(fontSize: 12),
        );
        return Row(
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 14,
              color: context.textTertiary,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                driving,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style,
              ),
            ),
            if (showWalking) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.directions_walk_outlined,
                size: 14,
                color: context.textTertiary,
              ),
              const SizedBox(width: 4),
              Text(
                walkingTime,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style,
              ),
            ],
          ],
        );
      },
    );
  }

  String _formatKm(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).round()} m';
    }
    final value = distanceInKm.toStringAsFixed(1).replaceAll('.', ',');
    return '$value km';
  }

  Widget _roundAction({
    required IconData icon,
    required String label,
    required Color background,
    required Color foreground,
    required VoidCallback? onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      tooltip: label,
      icon: Icon(icon, size: 20),
      style: IconButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        minimumSize: const Size(44, 44),
        fixedSize: const Size(44, 44),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: const CircleBorder(),
      ),
    );
  }

  Future<void> _callPharmacy() async {
    final uri = Uri.parse('tel:${widget.pharmacy.phone1}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }

  Future<void> _openDirections() async {
    if (!widget.pharmacy.hasGps) return;
    if (widget.userLatitude != null && widget.userLongitude != null) {
      final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&origin=${widget.userLatitude},${widget.userLongitude}&destination=${widget.pharmacy.latitude},${widget.pharmacy.longitude}&travelmode=driving',
      );
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (Platform.isAndroid) {
        try {
          final androidUri = Uri.parse(
            'google.navigation:q=${widget.pharmacy.latitude},${widget.pharmacy.longitude}',
          );
          if (await canLaunchUrl(androidUri)) {
            await launchUrl(androidUri, mode: LaunchMode.externalApplication);
          }
        } catch (e) {
          final geoUri = Uri.parse(
            'geo:${widget.pharmacy.latitude},${widget.pharmacy.longitude}?q=${widget.pharmacy.latitude},${widget.pharmacy.longitude}',
          );
          if (await canLaunchUrl(geoUri)) {
            await launchUrl(geoUri, mode: LaunchMode.externalApplication);
          }
        }
      }
    } else {
      final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${widget.pharmacy.latitude},${widget.pharmacy.longitude}',
      );
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (Platform.isAndroid) {
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

  String _getAddress() {
    final parts = <String>[];
    if (widget.pharmacy.commune != null &&
        widget.pharmacy.commune!.isNotEmpty) {
      parts.add(widget.pharmacy.commune!);
    }
    if (widget.pharmacy.city != null && widget.pharmacy.city!.isNotEmpty) {
      parts.add(widget.pharmacy.city!);
    }
    if (widget.pharmacy.district != null &&
        widget.pharmacy.district!.isNotEmpty) {
      parts.add(widget.pharmacy.district!);
    }
    return parts.isNotEmpty ? parts.join(', ') : 'Adresse non disponible';
  }
}

/// `true` si « 🚗 485 m · ≈ 4 min  🚶 ≈ 9 min » tient sur la ligne.
/// Sinon on garde seulement la distance et le temps en voiture.
bool fitsWalkingTime({
  required String driving,
  required String walkingTime,
  required double maxWidth,
  required TextStyle style,
  double iconSize = 14,
  double iconGap = 4,
  double groupGap = 8,
}) {
  double widthOf(String text) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return painter.width;
  }

  final needed =
      iconSize +
      iconGap +
      widthOf(driving) +
      groupGap +
      iconSize +
      iconGap +
      widthOf(walkingTime);
  return needed <= maxWidth;
}
