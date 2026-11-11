import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/storage_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _navigateToNextScreen();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
    
    // Vérifier si l'utilisateur est déjà connecté
    final cachedAuth = prefs.getString('cached_auth_response');
    final isLoggedIn = cachedAuth != null && cachedAuth.isNotEmpty;

    if (isLoggedIn) {
      context.navigateToAndRemoveUntil(AppRoutes.home);
    } else if (hasSeenOnboarding) {
      context.navigateToAndRemoveUntil(AppRoutes.login);
    } else {
      context.navigateToAndRemoveUntil(AppRoutes.onboarding);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.primaryDark,
      body: Container(
        color: context.primaryDark,
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
                  color: Colors.white,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Pin de localisation avec les couleurs de la Côte d'Ivoire
                    CustomPaint(
                      size: const Size(100, 100),
                      painter: IvoryCoastPinPainter(),
                    ),
                    // Étoile orange au-dessus
                    Positioned(
                      top: 10,
                      right: 20,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accent,
                        ),
                        child: const Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl3),
              Text(
                'Pharmacie de Garde',
                style: AppTypography.headlineMedium.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Trouvez votre pharmacie 24/7',
                style: AppTypography.bodyLarge.copyWith(
                  color: Colors.white.withValues(alpha: 0.78),
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

// Custom painter pour créer le pin avec les couleurs de la Côte d'Ivoire
class IvoryCoastPinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Dessiner le pin (forme de goutte inversée)
    final path = Path();
    path.moveTo(size.width / 2, size.height * 0.1);
    path.lineTo(size.width * 0.85, size.height * 0.3);
    path.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.5,
      size.width * 0.85,
      size.height * 0.7,
    );
    path.lineTo(size.width / 2, size.height * 0.9);
    path.lineTo(size.width * 0.15, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.1,
      size.height * 0.5,
      size.width * 0.15,
      size.height * 0.3,
    );
    path.close();

    // Diviser en 3 bandes verticales
    final clipPath1 = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width / 3, size.height));
    final clipPath2 = Path()
      ..addRect(Rect.fromLTWH(size.width / 3, 0, size.width / 3, size.height));
    final clipPath3 = Path()
      ..addRect(Rect.fromLTWH(size.width * 2 / 3, 0, size.width / 3, size.height));

    // Orange (gauche) - Accent
    canvas.save();
    canvas.clipPath(Path.combine(PathOperation.intersect, path, clipPath1));
    paint.color = AppColors.accent;
    canvas.drawPath(path, paint);
    canvas.restore();

    // Blanc (centre) avec croix verte
    canvas.save();
    canvas.clipPath(Path.combine(PathOperation.intersect, path, clipPath2));
    paint.color = Colors.white;
    canvas.drawPath(path, paint);
    // Croix verte au centre
    paint.color = AppColors.primary;
    paint.strokeWidth = 4;
    paint.style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width / 2, size.height * 0.35),
      Offset(size.width / 2, size.height * 0.65),
      paint,
    );
    canvas.drawLine(
      Offset(size.width / 2 - 8, size.height * 0.5),
      Offset(size.width / 2 + 8, size.height * 0.5),
      paint,
    );
    canvas.restore();

    // Vert (droite) - Primary
    canvas.save();
    canvas.clipPath(Path.combine(PathOperation.intersect, path, clipPath3));
    paint.color = AppColors.primary;
    paint.style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

