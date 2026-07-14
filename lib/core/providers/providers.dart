import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../network/api_client.dart';
import '../network/network_info.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/pharmacy/data/datasources/pharmacy_local_datasource.dart';
import '../../features/pharmacy/data/datasources/pharmacy_remote_datasource.dart';
import '../../features/pharmacy/data/repositories/pharmacy_repository_impl.dart';
import '../../features/emergency/data/datasources/emergency_local_datasource.dart';
import '../../features/emergency/data/datasources/emergency_remote_datasource.dart';
import '../../features/emergency/data/repositories/emergency_repository_impl.dart';
import '../../features/review/data/datasources/review_remote_datasource.dart';
import '../../features/review/data/repositories/review_repository_impl.dart';
import '../../features/pharmacy/data/datasources/pharmacy_report_datasource.dart';

// SharedPreferences Provider - Utilisé comme FutureProvider pour gérer l'async
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

// Provider pour passer SharedPreferences directement (utilisé avec override)
final sharedPreferencesInstanceProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesInstanceProvider doit être override avec une valeur');
});

// Network Providers
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(Connectivity());
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// Auth Providers - Utilise sharedPreferencesInstanceProvider qui doit être override
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesInstanceProvider);
  return AuthLocalDataSourceImpl(prefs);
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRemoteDataSourceImpl(apiClient);
});

final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  final localDataSource = ref.watch(authLocalDataSourceProvider);
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
  );
});

// Pharmacy Providers
final pharmacyRemoteDataSourceProvider = Provider<PharmacyRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PharmacyRemoteDataSourceImpl(apiClient);
});

final pharmacyLocalDataSourceProvider = Provider<PharmacyLocalDataSource>((ref) {
  return PharmacyLocalDataSourceImpl();
});

final pharmacyRepositoryProvider = Provider<PharmacyRepositoryImpl>((ref) {
  final remoteDataSource = ref.watch(pharmacyRemoteDataSourceProvider);
  final localDataSource = ref.watch(pharmacyLocalDataSourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  return PharmacyRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    networkInfo: networkInfo,
  );
});

// Emergency Providers - Utilise sharedPreferencesInstanceProvider qui doit être override
final emergencyLocalDataSourceProvider = Provider<EmergencyLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesInstanceProvider);
  return EmergencyLocalDataSourceImpl(prefs);
});

final emergencyRemoteDataSourceProvider = Provider<EmergencyRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return EmergencyRemoteDataSourceImpl(apiClient);
});

final emergencyRepositoryProvider = Provider<EmergencyRepositoryImpl>((ref) {
  final remoteDataSource = ref.watch(emergencyRemoteDataSourceProvider);
  final localDataSource = ref.watch(emergencyLocalDataSourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  return EmergencyRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    networkInfo: networkInfo,
  );
});

// Review Providers
final reviewRemoteDataSourceProvider = Provider<ReviewRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ReviewRemoteDataSourceImpl(apiClient);
});

final reviewRepositoryProvider = Provider<ReviewRepositoryImpl>((ref) {
  final remoteDataSource = ref.watch(reviewRemoteDataSourceProvider);
  return ReviewRepositoryImpl(remoteDataSource: remoteDataSource);
});

// Pharmacy Report Provider
final pharmacyReportDataSourceProvider = Provider<PharmacyReportDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PharmacyReportDataSourceImpl(apiClient);
});
