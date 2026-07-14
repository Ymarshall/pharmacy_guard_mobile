import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/emergency_number.dart';
import '../../domain/repositories/emergency_repository.dart';
import '../../../../core/providers/providers.dart' as providers;

class EmergencyState {
  final List<EmergencyNumber> emergencyNumbers;
  final bool isLoading;
  final String? error;
  final bool isFromCache;

  const EmergencyState({
    this.emergencyNumbers = const [],
    this.isLoading = false,
    this.error,
    this.isFromCache = false,
  });

  EmergencyState copyWith({
    List<EmergencyNumber>? emergencyNumbers,
    bool? isLoading,
    String? error,
    bool? isFromCache,
  }) {
    return EmergencyState(
      emergencyNumbers: emergencyNumbers ?? this.emergencyNumbers,
      isLoading: isLoading ?? this.isLoading,
      error: error == '' ? null : (error ?? this.error),
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }
}

class EmergencyNotifier extends StateNotifier<EmergencyState> {
  final EmergencyRepository repository;
  final NetworkInfo networkInfo;

  EmergencyNotifier(this.repository, this.networkInfo) : super(const EmergencyState());

  Future<void> getEmergencyNumbers() async {
    state = state.copyWith(isLoading: true, error: null);
    
    // Vérifier la connexion réseau
    final wasConnected = await networkInfo.isConnected;
    
    final result = await repository.getEmergencyNumbers();
    result.fold(
      (failure) {
        String message = 'Une erreur est survenue';
        bool fromCache = !wasConnected;
        
        if (failure is ServerFailure) {
          message = failure.message;
          // Si erreur serveur et qu'on était connecté, on a peut-être utilisé le cache
          fromCache = true;
        } else if (failure is NetworkFailure) {
          message = failure.message;
          // Erreur réseau = on utilise probablement le cache
          fromCache = true;
        } else if (failure is CacheFailure) {
          message = failure.message;
          fromCache = true;
        }
        
        state = state.copyWith(
          isLoading: false,
          error: message,
          isFromCache: fromCache,
        );
      },
      (emergencyNumbers) {
        // Si on n'était pas connecté, les données viennent du cache
        // Si on était connecté, on assume que les données viennent de l'API
        // NOTE: Si l'API échoue mais qu'on utilise le cache avec succès,
        // on ne peut pas le détecter ici. C'est une limitation du pattern Either.
        // Pour une vraie solution, il faudrait modifier le repository pour retourner
        // une structure qui inclut l'information sur la source (cache vs API).
        state = EmergencyState(
          emergencyNumbers: emergencyNumbers,
          isFromCache: !wasConnected,
        );
      },
    );
  }
}

final emergencyNotifierProvider = StateNotifierProvider<EmergencyNotifier, EmergencyState>((ref) {
  final repository = ref.watch(providers.emergencyRepositoryProvider);
  final networkInfo = ref.watch(providers.networkInfoProvider);
  return EmergencyNotifier(repository, networkInfo);
});
