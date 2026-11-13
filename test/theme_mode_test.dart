import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacie_de_garde/core/constants/storage_keys.dart';
import 'package:pharmacie_de_garde/core/providers/providers.dart';
import 'package:pharmacie_de_garde/core/theme/app_theme.dart';
import 'package:pharmacie_de_garde/core/theme/theme_mode_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('sans préférence, le thème est clair, même le soir', () {
    expect(AppTheme.resolveThemeMode(), ThemeMode.light);
    expect(AppTheme.resolveThemeMode(darkModeEnabled: null), ThemeMode.light);
    expect(AppTheme.resolveThemeMode(darkModeEnabled: false), ThemeMode.light);
    expect(AppTheme.getThemeMode(), ThemeMode.light);
  });

  test("le mode sombre ne s'active que si l'utilisateur l'a choisi", () {
    expect(AppTheme.resolveThemeMode(darkModeEnabled: true), ThemeMode.dark);
  });

  testWidgets(
    'le contrôleur persiste le choix et revient au clair par défaut',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      late ThemeMode mode;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesInstanceProvider.overrideWithValue(prefs),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              mode = ref.watch(themeModeProvider);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(mode, ThemeMode.light);
      expect(prefs.getBool(StorageKeys.darkModeEnabled), isNot(true));

      final container = ProviderScope.containerOf(
        tester.element(find.byType(Consumer)),
      );
      await container.read(themeModeProvider.notifier).setDarkMode(true);
      await tester.pump();
      expect(container.read(themeModeProvider), ThemeMode.dark);
      expect(prefs.getBool(StorageKeys.darkModeEnabled), isTrue);

      await container.read(themeModeProvider.notifier).setDarkMode(false);
      await tester.pump();
      expect(container.read(themeModeProvider), ThemeMode.light);
      expect(prefs.getBool(StorageKeys.darkModeEnabled), isFalse);
    },
  );
}
