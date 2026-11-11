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
  final bool needsRegistration;
  final bool needsLocation;
  final bool redirectToLogin;

  const AuthState({
    this.authResponse,
    this.isLoading = false,
    this.error,
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
    bool? needsRegistration,
    bool? needsLocation,
    bool? redirectToLogin,
  }) {
    return AuthState(
      authResponse: authResponse ?? this.authResponse,
      isLoading: isLoading ?? this.isLoading,
      error: error == '' ? null : (error ?? this.error),
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

  Future<void> loginWithPhone(String phone) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      needsRegistration: false,
      needsLocation: false,
      redirectToLogin: false,
    );
    final result = await authRepository.loginWithPhone(phone);
    result.fold((failure) {
      if (failure is NotFoundFailure) {
        state = AuthState(needsRegistration: true, error: failure.message);
      } else {
        state = AuthState(error: failure.message);
      }
    }, (authResponse) => state = AuthState(authResponse: authResponse));
  }

  /// Inscription : la réponse porte le jeton, stocké avant la géolocalisation.
  Future<void> registerClient({required String phone}) async {
    state = const AuthState(isLoading: true);
    final result = await authRepository.registerClient(phone: phone);
    result.fold(
      (failure) {
        if (failure is ConflictFailure) {
          state = AuthState(error: failure.message, redirectToLogin: true);
        } else {
          state = AuthState(error: failure.message);
        }
      },
      (authResponse) {
        state = AuthState(authResponse: authResponse, needsLocation: true);
      },
    );
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
