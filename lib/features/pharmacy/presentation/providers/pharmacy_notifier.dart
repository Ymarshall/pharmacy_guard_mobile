import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pharmacy.dart';
import '../../domain/repositories/pharmacy_repository.dart';
import '../../../../core/providers/providers.dart' as providers;

class PharmacyState {
  final List<Pharmacy> pharmacies;
  final bool isLoading;
  final String? error;

  const PharmacyState({
    this.pharmacies = const [],
    this.isLoading = false,
    this.error,
  });

  PharmacyState copyWith({
    List<Pharmacy>? pharmacies,
    bool? isLoading,
    String? error,
  }) {
    return PharmacyState(
      pharmacies: pharmacies ?? this.pharmacies,
      isLoading: isLoading ?? this.isLoading,
      error: error == '' ? null : (error ?? this.error),
    );
  }
}

class PharmacyNotifier extends StateNotifier<PharmacyState> {
  final PharmacyRepository pharmacyRepository;

  PharmacyNotifier(this.pharmacyRepository) : super(const PharmacyState());

  Future<void> getAllPharmacies() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await pharmacyRepository.getAllPharmacies();
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (pharmacies) => state = state.copyWith(
        pharmacies: pharmacies,
        isLoading: false,
      ),
    );
  }

  Future<void> getNearestDutyPharmacies({
    required double latitude,
    required double longitude,
    int limit = 3,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await pharmacyRepository.getNearestDutyPharmacies(
      latitude: latitude,
      longitude: longitude,
      limit: limit,
    );
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (pharmacies) => state = state.copyWith(
        pharmacies: pharmacies,
        isLoading: false,
      ),
    );
  }
}

final pharmacyNotifierProvider = StateNotifierProvider<PharmacyNotifier, PharmacyState>((ref) {
  final repository = ref.watch(providers.pharmacyRepositoryProvider);
  return PharmacyNotifier(repository);
});
