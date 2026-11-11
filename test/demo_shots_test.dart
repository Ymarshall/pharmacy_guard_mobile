import 'dart:io';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmacie_de_garde/core/errors/failures.dart';
import 'package:pharmacie_de_garde/core/network/network_info.dart';
import 'package:pharmacie_de_garde/core/providers/providers.dart';
import 'package:pharmacie_de_garde/core/theme/app_theme.dart';
import 'package:pharmacie_de_garde/features/pharmacy/data/datasources/pharmacy_local_datasource.dart';
import 'package:pharmacie_de_garde/features/pharmacy/data/datasources/pharmacy_remote_datasource.dart';
import 'package:pharmacie_de_garde/features/pharmacy/data/models/pharmacy_model.dart';
import 'package:pharmacie_de_garde/features/pharmacy/data/repositories/pharmacy_repository_impl.dart';
import 'package:pharmacie_de_garde/features/pharmacy/domain/entities/pharmacy.dart';
import 'package:pharmacie_de_garde/features/pharmacy/presentation/pages/pharmacy_detail_page.dart';
import 'package:pharmacie_de_garde/features/home/presentation/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fixtures/screenshot_pharmacies.dart';

/// Captures de démo, hors build de production.
/// SAVE_SHOTS=1 flutter test test/demo_shots_test.dart --update-goldens
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('liste remplie et fiche pharmacie', (tester) async {
    if (Platform.environment['SAVE_SHOTS'] != '1') return;
    GoogleFonts.config.allowRuntimeFetching = false;
    await _loadMaterialIcons(tester);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<void> shoot(String name) async {
      await tester.pump();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/$name.png'),
      );
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesInstanceProvider.overrideWithValue(prefs),
          pharmacyRepositoryProvider.overrideWith(
            (ref) => _ScreenshotPharmacyRepository(),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: const HomePage(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('PHARMACIE DES II PLATEAUX'), findsOneWidget);
    expect(find.text('PHARMACIE DU PLATEAU'), findsOneWidget);
    await shoot('08-garde');

    await tester.enterText(find.byType(TextField), 'PHARMACIE');
    await tester.pump();
    await tester.pump();

    expect(find.text('7 résultats'), findsOneWidget);
    expect(find.text('PHARMACIE DES II PLATEAUX'), findsOneWidget);
    await shoot('09-recherche');

    await tester.scrollUntilVisible(
      find.text('PHARMACIE DE MARCORY ZONE 4'),
      400,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pump();
    expect(find.text('Ouverte'), findsWidgets);
    await shoot('10-ouverte');

    await tester.scrollUntilVisible(
      find.text('PHARMACIE DE YOPOUGON NIANGON'),
      400,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pump();
    expect(find.text('PHARMACIE DE YOPOUGON NIANGON'), findsOneWidget);
    expect(find.text('Fermée'), findsWidgets);
    await shoot('11-fermee');

    final featured = screenshotPharmacies.first;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesInstanceProvider.overrideWithValue(prefs),
          pharmacyRepositoryProvider.overrideWith(
            (ref) => _ScreenshotPharmacyRepository(),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: PharmacyDetailPage(pharmacy: featured),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('PHARMACIE DES II PLATEAUX'), findsOneWidget);
    expect(find.text('+225 07 08 21 45 90'), findsOneWidget);
    await shoot('12-detail');

    await tester.ensureVisible(find.text('Itinéraire'));
    await tester.pump();
    expect(find.text('Horaires'), findsOneWidget);
    expect(find.text('Appeler'), findsWidgets);
    await shoot('13-detail-actions');
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
    ..addFont(Future<ByteData>.value(ByteData.sublistView(Uint8List.fromList(bytes))));
  await loader.load();
}

class _OfflineNetwork implements NetworkInfo {
  @override
  Future<bool> get isConnected async => false;
}

class _UnusedRemote implements PharmacyRemoteDataSource {
  @override
  Future<List<PharmacyModel>> getAllPharmacies() async => const [];

  @override
  Future<PharmacyModel> getPharmacyById(String id) async =>
      screenshotPharmacies.first;

  @override
  Future<List<PharmacyModel>> getNearestDutyPharmacies({
    required double latitude,
    required double longitude,
    int limit = 3,
  }) async =>
      const [];

  @override
  Future<List<PharmacyModel>> getNearestPharmacies({
    required double latitude,
    required double longitude,
    double radius = 10.0,
  }) async =>
      const [];

  @override
  Future<List<PharmacyModel>> getPharmaciesOnDuty({
    required double latitude,
    required double longitude,
    double radius = 10.0,
  }) async =>
      const [];
}

class _ScreenshotPharmacyRepository extends PharmacyRepositoryImpl {
  _ScreenshotPharmacyRepository()
      : super(
          remoteDataSource: _UnusedRemote(),
          localDataSource: PharmacyLocalDataSourceImpl(),
          networkInfo: _OfflineNetwork(),
        );

  @override
  Future<Either<Failure, List<Pharmacy>>> getAllPharmacies() async {
    return const Right(screenshotPharmacies);
  }

  @override
  Future<Either<Failure, List<Pharmacy>>> getNearestDutyPharmacies({
    required double latitude,
    required double longitude,
    int limit = 3,
  }) async {
    final duty = screenshotPharmacies.where((pharmacy) => pharmacy.isOnDuty);
    return Right(duty.take(limit).toList());
  }

  @override
  Future<Either<Failure, List<Pharmacy>>> getNearestPharmacies({
    required double latitude,
    required double longitude,
    double radius = 10.0,
  }) async {
    return const Right(screenshotPharmacies);
  }

  @override
  Future<Either<Failure, List<Pharmacy>>> getPharmaciesOnDuty({
    required double latitude,
    required double longitude,
    double radius = 10.0,
  }) async {
    return Right(
      screenshotPharmacies.where((pharmacy) => pharmacy.isOnDuty).toList(),
    );
  }

  @override
  Future<Either<Failure, Pharmacy>> getPharmacyById(String id) async {
    return Right(
      screenshotPharmacies.firstWhere((pharmacy) => pharmacy.id == id),
    );
  }
}
