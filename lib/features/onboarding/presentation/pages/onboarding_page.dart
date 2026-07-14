import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../config/themes/colors.dart';
import '../../../../shared/extensions/context_extensions.dart';
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
      icon: Icons.local_pharmacy,
      color: AppColors.primary,
    ),
    OnboardingItemData(
      title: 'Pharmacies de garde',
      description:
          'Accédez à la liste complète des pharmacies de garde disponibles dans votre région.',
      icon: Icons.medical_services,
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
    
    // Vérifier si l'utilisateur est déjà connecté
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
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: const Text(
                  'Passer',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            // Page view
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
            // Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _onboardingItems.length,
                (index) => _buildIndicator(index == _currentPage),
              ),
            ),
            const SizedBox(height: 32),
            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _onboardingItems.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _completeOnboarding();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _currentPage < _onboardingItems.length - 1
                        ? 'Suivant'
                        : 'Commencer',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.divider,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

