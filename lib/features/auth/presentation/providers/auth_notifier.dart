import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/security/reconnect_gate.dart';
import '../../domain/entities/auth_response.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/providers/providers.dart' as providers;

class AuthState {
  final AuthResponse? authResponse;
  final bool isLoading;
  final String? error;
  final String? phoneError;
  final bool needsRegistration;
  final bool needsLocation;
  final bool redirectToLogin;

  const AuthState({
    this.authResponse,
    this.isLoading = false,
    this.error,
    this.phoneError,
    this.needsRegistration = false,
    this.needsLocation = false,
    this.redirectToLogin = false,
  });

  bool get isAuthenticated => authResponse != null;
  bool get isUnauthenticated => authResponse == null && !isLoading;

  AuthState copyWith({
    AuthResponse? authResponse,
    bool? isLoading,
    String? error,
    String? phoneError,
    bool clearPhoneError = false,
    bool? needsRegistration,
    bool? needsLocation,
    bool? redirectToLogin,
  }) {
    return AuthState(
      authResponse: authResponse ?? this.authResponse,
      isLoading: isLoading ?? this.isLoading,
      error: error == '' ? null : (error ?? this.error),
      phoneError: clearPhoneError ? null : (phoneError ?? this.phoneError),
      needsRegistration: needsRegistration ?? this.needsRegistration,
      needsLocation: needsLocation ?? this.needsLocation,
      redirectToLogin: redirectToLogin ?? this.redirectToLogin,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository authRepository;
  final ReconnectGate reconnectGate;

  AuthNotifier(this.authRepository, this.reconnectGate)
    : super(const AuthState()) {
    reconnectGate.onResolved = (success) {
      if (!success) {
        state = const AuthState();
        authRepository.signOut();
      }
    };
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final result = await authRepository.getCurrentAuth();
    result.fold(
      (failure) => state = const AuthState(),
      (authResponse) => state = AuthState(authResponse: authResponse),
    );
  }

  Future<void> loginWithPhone(
    String phone, {
    bool offerRegistration = true,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: '',
      clearPhoneError: true,
      needsRegistration: false,
      needsLocation: false,
      redirectToLogin: false,
    );
    final result = await authRepository.loginWithPhone(phone);
    _applyLogin(result, offerRegistration: offerRegistration);
  }

  void _applyLogin(
    Either<Failure, AuthResponse> result, {
    required bool offerRegistration,
  }) {
    result.fold((failure) {
      if (failure is NotFoundFailure && offerRegistration) {
        state = const AuthState(needsRegistration: true);
      } else if (failure is ValidationFailure) {
        state = AuthState(
          phoneError: failure.fieldErrors['phone'] ?? failure.message,
        );
      } else {
        state = AuthState(error: failure.message);
      }
    }, (authResponse) => state = AuthState(authResponse: authResponse));
  }

  /// Inscription publique, puis jeton, puis géolocalisation.
  /// Un 409 relance le login une fois, sans réouvrir l'inscription.
  Future<void> registerClient({required String phone}) async {
    state = const AuthState(isLoading: true);
    final result = await authRepository.registerClient(phone: phone);
    final failure = result.fold<Failure?>((error) => error, (_) => null);
    if (failure is ConflictFailure) {
      final login = await authRepository.loginWithPhone(phone);
      final loggedIn = login.fold<AuthResponse?>((_) => null, (auth) => auth);
      if (loggedIn != null) {
        state = AuthState(authResponse: loggedIn);
      } else {
        state = AuthState(error: failure.message);
      }
      return;
    }
    if (failure is ValidationFailure) {
      state = AuthState(
        phoneError: failure.fieldErrors['phone'] ?? failure.message,
      );
      return;
    }
    if (failure != null) {
      state = AuthState(error: failure.message);
      return;
    }
    final authResponse = result.fold((_) => null, (auth) => auth);
    state = AuthState(authResponse: authResponse, needsLocation: true);
  }

  Future<void> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    final clientId = state.authResponse?.client.id;
    final session = state.authResponse;
    if (clientId == null || session == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'Compte introuvable pour enregistrer la position.',
      );
      return;
    }
    state = state.copyWith(isLoading: true, error: '');
    final result = await authRepository.updateLocation(
      clientId: clientId,
      latitude: latitude,
      longitude: longitude,
    );
    result.fold(
      (failure) =>
          state = AuthState(
            authResponse: session,
            needsLocation: true,
            error: failure.message,
          ),
      (_) => state = AuthState(authResponse: session),
    );
  }

  void clearPhoneError() {
    if (state.phoneError == null) return;
    state = state.copyWith(clearPhoneError: true);
  }

  Future<void> signOut() async {
    final result = await authRepository.signOut();
    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) => state = const AuthState(),
    );
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  final repository = ref.watch(providers.authRepositoryProvider);
  final gate = ref.watch(providers.reconnectGateProvider);
  return AuthNotifier(repository, gate);
});
