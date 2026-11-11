import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../config/routes/app_routes.dart';
import '../widgets/onboarding_item.dart' show OnboardingItem, OnboardingItemData;

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItemData> _onboardingItems = [
    OnboardingItemData(
      title: 'Trouvez votre pharmacie',
      description:
          'Localisez rapidement les pharmacies de garde les plus proches de vous, 24h/24 et 7j/7.',
      icon: Icons.local_pharmacy_outlined,
      color: AppColors.primary,
    ),
    OnboardingItemData(
      title: 'Pharmacies de garde',
      description:
          'Accédez à la liste complète des pharmacies de garde disponibles dans votre région.',
      icon: Icons.medical_services_outlined,
      color: AppColors.primaryLight,
    ),
    OnboardingItemData(
      title: 'Informations détaillées',
      description:
          'Consultez les horaires, coordonnées et distances de chaque pharmacie en temps réel.',
      icon: Icons.info_outline,
      color: AppColors.accent,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);

    if (!mounted) return;

    final cachedUser = prefs.getString('cached_user');
    final isLoggedIn = cachedUser != null && cachedUser.isNotEmpty;

    if (isLoggedIn) {
      context.navigateToAndRemoveUntil(AppRoutes.home);
    } else {
      context.navigateToAndRemoveUntil(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage >= _onboardingItems.length - 1;

    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    'Passer',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: context.textSecondary,
                        ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _onboardingItems.length,
                itemBuilder: (context, index) {
                  return OnboardingItem(
                    data: _onboardingItems[index],
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _onboardingItems.length,
                (index) => _buildIndicator(index == _currentPage),
              ),
            ),
            const SizedBox(height: AppSpacing.xl2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: PrimaryButton(
                label: isLast ? 'Commencer' : 'Suivant',
                onPressed: () {
                  if (!isLast) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    _completeOnboarding();
                  }
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xl2),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 22 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: isActive ? context.primary : context.divider,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusPill),
      ),
    );
  }
}
