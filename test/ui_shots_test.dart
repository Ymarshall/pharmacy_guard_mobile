import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacie_de_garde/core/network/network_info.dart';
import 'package:pharmacie_de_garde/core/providers/providers.dart';
import 'package:pharmacie_de_garde/core/theme/app_theme.dart';
import 'package:pharmacie_de_garde/features/about/presentation/pages/about_page.dart';
import 'package:pharmacie_de_garde/features/auth/presentation/pages/login_page.dart';
import 'package:pharmacie_de_garde/features/help/presentation/pages/help_page.dart';
import 'package:pharmacie_de_garde/features/home/presentation/pages/home_page.dart';
import 'package:pharmacie_de_garde/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:pharmacie_de_garde/features/settings/presentation/pages/settings_page.dart';
import 'package:pharmacie_de_garde/features/splash/presentation/pages/splash_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _OfflineNetwork implements NetworkInfo {
  @override
  Future<bool> get isConnected async => false;
}

/// Captures hors CI : SAVE_SHOTS=1 flutter test test/ui_shots_test.dart
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('captures des écrans principaux', (tester) async {
    if (Platform.environment['SAVE_SHOTS'] != '1') return;
    GoogleFonts.config.allowRuntimeFetching = false;
    await _loadMaterialIcons(tester);
    final previousOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      final message = details.exceptionAsString();
      if (message.contains('google_fonts') || message.contains('GoogleFonts')) {
        return;
      }
      previousOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = previousOnError);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<void> shoot(
      Widget home,
      String name, {
      bool scoped = false,
      Duration settle = const Duration(milliseconds: 50),
    }) async {
      final app = MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: home,
      );
      await tester.pumpWidget(
        scoped
            ? ProviderScope(
                overrides: [
                  sharedPreferencesInstanceProvider.overrideWithValue(prefs),
                  networkInfoProvider.overrideWith((ref) => _OfflineNetwork()),
                ],
                child: RepaintBoundary(child: app),
              )
            : RepaintBoundary(child: app),
      );
      await tester.pump();
      await tester.pump(settle);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/$name.png'),
      );
    }

    await shoot(
      const SplashPage(),
      '01-splash',
      settle: const Duration(milliseconds: 1600),
    );
    await shoot(const OnboardingPage(), '02-onboarding');
    await shoot(const LoginPage(), '03-login', scoped: true);
    await shoot(const HomePage(), '04-home', scoped: true);
    await shoot(const HelpPage(), '05-aide');
    await shoot(const AboutPage(), '06-a-propos');
    await shoot(const SettingsPage(), '07-parametres', scoped: true);

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pump(const Duration(seconds: 4));
  });
}

Future<void> _loadMaterialIcons(WidgetTester tester) async {
  final root = Platform.environment['FLUTTER_ROOT'] ??
      '${Platform.environment['HOME']}/flutter-sdk/flutter';
  final file = File(
    '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  if (!file.existsSync()) return;
  final bytes = await tester.runAsync(() => file.readAsBytes());
  if (bytes == null) return;
  final loader = FontLoader('MaterialIcons')
    ..addFont(
      Future<ByteData>.value(ByteData.sublistView(Uint8List.fromList(bytes))),
    );
  await loader.load();
}
