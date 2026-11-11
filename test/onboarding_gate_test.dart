import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacie_de_garde/config/routes/app_routes.dart';
import 'package:pharmacie_de_garde/core/constants/storage_keys.dart';
import 'package:pharmacie_de_garde/core/providers/providers.dart';
import 'package:pharmacie_de_garde/core/security/token_vault.dart';
import 'package:pharmacie_de_garde/core/theme/app_theme.dart';
import 'package:pharmacie_de_garde/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:pharmacie_de_garde/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pharmacie_de_garde/features/auth/data/models/auth_response_model.dart';
import 'package:pharmacie_de_garde/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:pharmacie_de_garde/features/auth/presentation/pages/login_page.dart';
import 'package:pharmacie_de_garde/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:pharmacie_de_garde/features/onboarding/startup_destination.dart';
import 'package:pharmacie_de_garde/features/splash/presentation/pages/splash_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/memory_secure_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('premier lancement, puis session, puis simple connexion', () {
    expect(
      resolveAppStart(onboardingCompleted: false, hasValidSession: false),
      AppStart.onboarding,
    );
    expect(
      resolveAppStart(onboardingCompleted: false, hasValidSession: true),
      AppStart.onboarding,
    );
    expect(
      resolveAppStart(onboardingCompleted: true, hasValidSession: false),
      AppStart.login,
    );
    expect(
      resolveAppStart(onboardingCompleted: true, hasValidSession: true),
      AppStart.home,
    );
  });

  testWidgets(
    'le premier lancement affiche l\'onboarding, sans l\'avoir montré avant',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(_app(prefs, onboardingCompleted: false));
      await tester.pump();
      expect(find.byType(OnboardingPage), findsNothing);
      expect(find.text('Passer'), findsNothing);

      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingPage), findsOneWidget);
      expect(find.text('Passer'), findsOneWidget);
      expect(prefs.getBool(StorageKeys.onboardingCompleted), isNot(true));
    },
  );

  testWidgets('Terminer enregistre le booléen et ouvre la connexion', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(_onboardingApp(prefs));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    expect(find.text('Terminer'), findsOneWidget);

    await tester.tap(find.text('Terminer'));
    await tester.pumpAndSettle();

    expect(prefs.getBool(StorageKeys.onboardingCompleted), isTrue);
    expect(find.text('Connexion'), findsOneWidget);
    expect(find.byType(OnboardingPage), findsNothing);
  });

  testWidgets('Passer enregistre le booléen et ouvre la connexion', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(_onboardingApp(prefs));
    await tester.tap(find.text('Passer'));
    await tester.pumpAndSettle();

    expect(prefs.getBool(StorageKeys.onboardingCompleted), isTrue);
    expect(find.text('Connexion'), findsOneWidget);
  });

  testWidgets('après onboarding, le splash n\'affiche jamais l\'onboarding', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      StorageKeys.onboardingCompleted: true,
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(_app(prefs, onboardingCompleted: true));
    await tester.pump();
    expect(find.byType(OnboardingPage), findsNothing);

    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingPage), findsNothing);
    expect(find.text('Passer'), findsNothing);
    expect(find.text('Connexion'), findsOneWidget);
    expect(prefs.getBool(StorageKeys.onboardingCompleted), isTrue);
  });

  test('la déconnexion ne remet pas onboardingCompleted à false', () async {
    SharedPreferences.setMockInitialValues({
      StorageKeys.onboardingCompleted: true,
    });
    final prefs = await SharedPreferences.getInstance();
    final repository = AuthRepositoryImpl(
      remoteDataSource: _SilentRemote(),
      localDataSource: AuthLocalDataSourceImpl(prefs),
      tokenVault: TokenVault(store: MemorySecureKeyValueStore()),
    );

    final signedOut = await repository.signOut();
    expect(signedOut.isRight(), isTrue);
    expect(prefs.getBool(StorageKeys.onboardingCompleted), isTrue);
    expect(
      resolveAppStart(
        onboardingCompleted: prefs.getBool(StorageKeys.onboardingCompleted)!,
        hasValidSession: false,
      ),
      AppStart.login,
    );
  });
}

Widget _app(SharedPreferences prefs, {required bool onboardingCompleted}) {
  return ProviderScope(
    overrides: [
      sharedPreferencesInstanceProvider.overrideWithValue(prefs),
      secureStoreProvider.overrideWithValue(MemorySecureKeyValueStore()),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash:
            (_) => SplashPage(
              onboardingCompleted: onboardingCompleted,
              hold: Duration.zero,
            ),
        AppRoutes.onboarding: (_) => const OnboardingPage(),
        AppRoutes.login: (_) => const LoginPage(),
      },
    ),
  );
}

Widget _onboardingApp(SharedPreferences prefs) {
  return ProviderScope(
    overrides: [
      sharedPreferencesInstanceProvider.overrideWithValue(prefs),
      secureStoreProvider.overrideWithValue(MemorySecureKeyValueStore()),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      home: const OnboardingPage(),
      routes: {AppRoutes.login: (_) => const LoginPage()},
    ),
  );
}

class _SilentRemote implements AuthRemoteDataSource {
  @override
  Future<AuthResponseModel> login(String phone) => throw UnimplementedError();

  @override
  Future<AuthResponseModel> register({required String phone}) =>
      throw UnimplementedError();

  @override
  Future<void> updateLocation({
    required int clientId,
    required double latitude,
    required double longitude,
  }) => throw UnimplementedError();
}
