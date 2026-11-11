import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacie_de_garde/core/errors/failures.dart';
import 'package:pharmacie_de_garde/core/providers/providers.dart';
import 'package:pharmacie_de_garde/core/security/reconnect_gate.dart';
import 'package:pharmacie_de_garde/core/theme/app_theme.dart';
import 'package:pharmacie_de_garde/core/utils/ivorian_phone.dart';
import 'package:pharmacie_de_garde/features/auth/data/models/auth_response_model.dart';
import 'package:pharmacie_de_garde/features/auth/data/models/client_model.dart';
import 'package:pharmacie_de_garde/features/auth/domain/entities/auth_response.dart';
import 'package:pharmacie_de_garde/features/auth/domain/repositories/auth_repository.dart';
import 'package:pharmacie_de_garde/features/auth/presentation/pages/login_page.dart';
import 'package:pharmacie_de_garde/features/auth/presentation/providers/auth_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const phone = '+225 07 12 34 56 78';
  const conflict = 'Un client avec ce numéro de téléphone existe déjà';

  AuthResponse session() {
    return AuthResponseModel(
      client: const ClientModel(
        id: 8,
        phone: phone,
        latitude: null,
        longitude: null,
        providerType: 'PHONE',
        isActive: true,
      ),
      nearestDutyPharmacies: const [],
      token: 'jwt-existant',
      tokenType: 'Bearer',
      expiresInSeconds: 86400,
    );
  }

  test('un 409 relance le login sans réouvrir l\'inscription', () async {
    final repo = _ScriptedRepository();
    final notifier = AuthNotifier(repo, ReconnectGate());
    await Future<void>.delayed(Duration.zero);

    repo.loginResult = const Left(NotFoundFailure('Numéro de téléphone non trouvé'));
    await notifier.loginWithPhone(phone);
    expect(notifier.state.needsRegistration, isTrue);

    repo.registerResult = const Left(ConflictFailure(conflict));
    repo.loginResult = Right(session());
    await notifier.registerClient(phone: phone);

    expect(notifier.state.isAuthenticated, isTrue);
    expect(notifier.state.needsRegistration, isFalse);
    expect(notifier.state.needsLocation, isFalse);
    expect(notifier.state.authResponse?.token, 'jwt-existant');
    expect(repo.loginCalls, 2);
  });

  test('un 400 pose le message sous le numéro, pas comme erreur générale', () async {
    final repo = _ScriptedRepository();
    final notifier = AuthNotifier(repo, ReconnectGate());
    await Future<void>.delayed(Duration.zero);

    repo.registerResult = const Left(
      ValidationFailure(
        IvorianPhone.invalidMessage,
        fieldErrors: {'phone': IvorianPhone.invalidMessage},
      ),
    );
    await notifier.registerClient(phone: phone);

    expect(notifier.state.phoneError, IvorianPhone.invalidMessage);
    expect(notifier.state.error, isNull);
    expect(notifier.state.isAuthenticated, isFalse);
  });

  testWidgets('l\'erreur serveur du téléphone s\'affiche sous le champ', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = _ScriptedRepository()
      ..loginResult = const Left(
        ValidationFailure(
          IvorianPhone.invalidMessage,
          fieldErrors: {'phone': IvorianPhone.invalidMessage},
        ),
      );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesInstanceProvider.overrideWithValue(prefs),
          authRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const LoginPage()),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextFormField), phone);
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();

    expect(find.text(IvorianPhone.invalidMessage), findsOneWidget);
    expect(repo.loginCalls, 1);
  });

  testWidgets('un numéro non ivoirien est refusé avant l\'appel', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = _ScriptedRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesInstanceProvider.overrideWithValue(prefs),
          authRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const LoginPage()),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextFormField), '+33 6 12 34 56 78');
    await tester.tap(find.text('Se connecter'));
    await tester.pump();

    expect(find.text(IvorianPhone.invalidMessage), findsOneWidget);
    expect(repo.loginCalls, 0);
  });
}

class _ScriptedRepository implements AuthRepository {
  Either<Failure, AuthResponse> loginResult = const Left(
    NotFoundFailure('Numéro de téléphone non trouvé'),
  );
  Either<Failure, AuthResponse> registerResult = const Left(
    NotFoundFailure('Numéro de téléphone non trouvé'),
  );
  int loginCalls = 0;

  @override
  Future<Either<Failure, AuthResponse?>> getCurrentAuth() async =>
      const Right(null);

  @override
  Future<Either<Failure, AuthResponse>> loginWithPhone(String phone) async {
    loginCalls++;
    return loginResult;
  }

  @override
  Future<Either<Failure, AuthResponse>> registerClient({
    required String phone,
  }) async => registerResult;

  @override
  Future<Either<Failure, void>> signOut() async => const Right(null);

  @override
  Future<Either<Failure, void>> updateLocation({
    required int clientId,
    required double latitude,
    required double longitude,
  }) async => const Right(null);
}
