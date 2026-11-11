import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/themes/app_theme.dart';
import 'config/routes/app_routes.dart';
import 'core/providers/providers.dart';
import 'features/splash/presentation/pages/splash_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/home/presentation/pages/home_page.dart';

class App extends StatelessWidget {
  final SharedPreferences sharedPreferences;

  const App({super.key, required this.sharedPreferences});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        // Override le provider avec la valeur déjà chargée
        sharedPreferencesInstanceProvider.overrideWithValue(sharedPreferences),
      ],
      child: const _PharmacieApp(),
    );
  }
}

class _PharmacieApp extends ConsumerWidget {
  const _PharmacieApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      navigatorKey: ref.watch(reconnectGateProvider).navigatorKey,
      title: 'Pharmacie de Garde',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: AppTheme.getThemeMode(),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashPage(),
        AppRoutes.onboarding: (context) => const OnboardingPage(),
        AppRoutes.login: (context) => const LoginPage(),
        AppRoutes.home: (context) => const HomePage(),
      },
    );
  }
}
