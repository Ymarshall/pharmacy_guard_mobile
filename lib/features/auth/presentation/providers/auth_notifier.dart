import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/auth_response.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/providers/providers.dart' as providers;

class AuthState {
  final AuthResponse? authResponse;
  final bool isLoading;
  final String? error;
  final bool needsLocation; // Indique si on a besoin de la géolocalisation pour créer le compte

  const AuthState({
    this.authResponse,
    this.isLoading = false,
    this.error,
    this.needsLocation = false,
  });

  bool get isAuthenticated => authResponse != null;
  bool get isUnauthenticated => authResponse == null && !isLoading;

  AuthState copyWith({
    AuthResponse? authResponse,
    bool? isLoading,
    String? error,
    bool? needsLocation,
  }) {
    return AuthState(
      authResponse: authResponse ?? this.authResponse,
      isLoading: isLoading ?? this.isLoading,
      error: error == '' ? null : (error ?? this.error),
      needsLocation: needsLocation ?? this.needsLocation,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository authRepository;

  AuthNotifier(this.authRepository) : super(const AuthState()) {
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
    state = state.copyWith(isLoading: true, error: null, needsLocation: false);
    final result = await authRepository.loginWithPhone(phone);
    result.fold(
      (failure) {
        if (failure is NotFoundFailure) {
          // Client n'existe pas, on a besoin de la géolocalisation
          state = state.copyWith(
            isLoading: false,
            needsLocation: true,
            error: failure.message,
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
          );
        }
      },
      (authResponse) => state = AuthState(authResponse: authResponse),
    );
  }

  Future<void> createClientAndLogin({
    required String phone,
    required double latitude,
    required double longitude,
  }) async {
    state = state.copyWith(isLoading: true, error: null, needsLocation: false);
    final result = await authRepository.createClientAndLogin(
      phone: phone,
      latitude: latitude,
      longitude: longitude,
    );
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (authResponse) => state = AuthState(authResponse: authResponse),
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

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(providers.authRepositoryProvider);
  return AuthNotifier(repository);
});
