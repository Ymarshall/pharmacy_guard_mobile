import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacie_de_garde/config/themes/colors.dart';
import 'package:pharmacie_de_garde/core/providers/providers.dart';
import 'package:pharmacie_de_garde/core/theme/app_theme.dart';
import 'package:pharmacie_de_garde/features/about/presentation/pages/about_page.dart';
import 'package:pharmacie_de_garde/features/auth/presentation/pages/login_page.dart';
import 'package:pharmacie_de_garde/features/help/presentation/pages/help_page.dart';
import 'package:pharmacie_de_garde/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:pharmacie_de_garde/features/settings/presentation/pages/settings_page.dart';
import 'package:pharmacie_de_garde/shared/widgets/primary_button.dart';
import 'package:pharmacie_de_garde/shared/widgets/status_badge.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('le thème clair conserve le vert de marque', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: Text('Pharmacie de Garde')),
      ),
    );

    final context = tester.element(find.text('Pharmacie de Garde'));
    final theme = Theme.of(context);
    expect(theme.colorScheme.primary, AppColors.primary);
    expect(theme.colorScheme.secondary, AppColors.accent);
    expect(theme.useMaterial3, isTrue);
    expect(theme.appBarTheme.centerTitle, isFalse);
    expect(theme.elevatedButtonTheme.style?.elevation?.resolve({}), 0);
  });

  testWidgets('les écrans principaux affichent le texte français', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesInstanceProvider.overrideWithValue(prefs),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const LoginPage(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Connexion'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
    expect(find.byType(PrimaryButton), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const OnboardingPage(),
      ),
    );
    await tester.pump();
    expect(find.text('Passer'), findsOneWidget);
    expect(find.text('Trouvez votre pharmacie'), findsOneWidget);
    expect(find.text('Suivant'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const HelpPage()),
    );
    await tester.pump();
    expect(find.text('Aide'), findsOneWidget);
    expect(find.text('Comment utiliser l\'application'), findsOneWidget);
    expect(find.text('Rechercher une pharmacie'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const AboutPage()),
    );
    await tester.pump();
    expect(find.text('À propos'), findsOneWidget);
    expect(find.text('Pharmacie de Garde'), findsOneWidget);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: const SettingsPage(),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Paramètres'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.byType(StatusBadge), findsNothing);
  });
}
