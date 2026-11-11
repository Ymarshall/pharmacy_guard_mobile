import 'package:flutter/material.dart';

/// Échelle d'espacement, de rayons et de cibles tactiles.
/// Reprend la grille du design system de référence.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xl2 = 24;
  static const double xl3 = 32;
  static const double xl4 = 48;

  static const paddingXs = EdgeInsets.all(xs);
  static const paddingSm = EdgeInsets.all(sm);
  static const paddingMd = EdgeInsets.all(md);
  static const paddingLg = EdgeInsets.all(lg);
  static const paddingXl = EdgeInsets.all(xl);
  static const paddingXl2 = EdgeInsets.all(xl2);

  static const horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const horizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const horizontalXl = EdgeInsets.symmetric(horizontal: xl);

  static const verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const verticalLg = EdgeInsets.symmetric(vertical: lg);

  static const screenPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: sm,
  );

  static const double borderRadius = 16;
  static const double borderRadiusSm = 10;
  static const double borderRadiusLg = 20;
  static const double borderRadiusPill = 999;

  /// Rayon des boutons et champs (composants du design system de référence).
  static const double controlRadius = 12;

  static const double touchTargetMin = 48;
  static const double buttonHeight = 52;
}
