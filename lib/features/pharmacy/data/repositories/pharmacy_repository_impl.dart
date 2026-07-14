import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/pharmacy.dart';
import '../../domain/repositories/pharmacy_repository.dart';
import '../datasources/pharmacy_local_datasource.dart';
import '../datasources/pharmacy_remote_datasource.dart';

class PharmacyRepositoryImpl implements PharmacyRepository {
  final PharmacyRemoteDataSource remoteDataSource;
  final PharmacyLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  PharmacyRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Pharmacy>>> getAllPharmacies() async {
    final isConnected = await networkInfo.isConnected;
    print('📡 [PHARMACY REPO] getAllPharmacies - Connected: $isConnected');
    
    if (isConnected) {
      try {
        print('📡 [PHARMACY REPO] Récupération depuis l\'API...');
        final pharmacies = await remoteDataSource.getAllPharmacies();
        print('✅ [PHARMACY REPO] ${pharmacies.length} pharmacies récupérées depuis l\'API');
        
        // Sauvegarder en local pour utilisation hors ligne
        print('💾 [PHARMACY REPO] Mise à jour du cache local...');
        await localDataSource.cachePharmacies(pharmacies);
        print('✅ [PHARMACY REPO] Cache local mis à jour avec ${pharmacies.length} pharmacies');
        
        return Right(pharmacies);
      } on ServerException catch (e) {
        // En cas d'erreur serveur, essayer le cache local
        print('⚠️ [PHARMACY REPO] Erreur serveur, tentative de récupération depuis le cache...');
        try {
          final cachedPharmacies = await localDataSource.getCachedPharmacies();
          if (cachedPharmacies.isNotEmpty) {
            print('✅ [PHARMACY REPO] ${cachedPharmacies.length} pharmacies récupérées depuis le cache (erreur serveur)');
            return Right(cachedPharmacies);
          }
        } catch (_) {
          print('❌ [PHARMACY REPO] Aucune donnée en cache disponible');
        }
        return Left(ServerFailure(e.message));
      } on NetworkException catch (e) {
        // En cas d'erreur réseau, utiliser le cache local
        print('⚠️ [PHARMACY REPO] Erreur réseau, tentative de récupération depuis le cache...');
        try {
          final cachedPharmacies = await localDataSource.getCachedPharmacies();
          if (cachedPharmacies.isNotEmpty) {
            print('✅ [PHARMACY REPO] ${cachedPharmacies.length} pharmacies récupérées depuis le cache (erreur réseau)');
            return Right(cachedPharmacies);
          }
        } catch (_) {
          print('❌ [PHARMACY REPO] Aucune donnée en cache disponible');
        }
        return Left(NetworkFailure(e.message));
      } catch (e) {
        if (e is AppException) {
          return Left(ServerFailure(e.message));
        }
        // En cas d'erreur inattendue, essayer le cache
        try {
          final cachedPharmacies = await localDataSource.getCachedPharmacies();
          if (cachedPharmacies.isNotEmpty) {
            return Right(cachedPharmacies);
          }
        } catch (_) {
          // Ignorer les erreurs de cache
        }
        return Left(ServerFailure('Erreur lors de la récupération des pharmacies: ${e.toString()}'));
      }
    } else {
      // Mode hors ligne: utiliser le cache local
      print('📴 [PHARMACY REPO] Mode hors ligne, récupération depuis le cache...');
      try {
        final cachedPharmacies = await localDataSource.getCachedPharmacies();
        if (cachedPharmacies.isNotEmpty) {
          print('✅ [PHARMACY REPO] ${cachedPharmacies.length} pharmacies récupérées depuis le cache (hors ligne)');
          return Right(cachedPharmacies);
        }
        print('❌ [PHARMACY REPO] Aucune donnée en cache disponible');
        return const Left(NetworkFailure('Pas de connexion internet et aucune donnée en cache'));
      } catch (e) {
        print('❌ [PHARMACY REPO] Erreur lors de la récupération du cache: $e');
        return Left(CacheFailure('Erreur lors de la récupération du cache: ${e.toString()}'));
      }
    }
  }

  @override
  Future<Either<Failure, List<Pharmacy>>> getNearestDutyPharmacies({
    required double latitude,
    required double longitude,
    int limit = 3,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final pharmacies = await remoteDataSource.getNearestDutyPharmacies(
          latitude: latitude,
          longitude: longitude,
          limit: limit,
        );
        // Optionnel: sauvegarder en cache local
        return Right(pharmacies);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } catch (e) {
        if (e is AppException) {
          return Left(ServerFailure(e.message));
        }
        return Left(ServerFailure('Erreur lors de la récupération des pharmacies: ${e.toString()}'));
      }
    } else {
      // Mode hors ligne: retourner les données en cache si disponibles
      try {
        final cachedPharmacies = await localDataSource.getCachedPharmacies();
        if (cachedPharmacies.isNotEmpty) {
          return Right(cachedPharmacies);
        }
        return Left(NetworkFailure('Aucune connexion internet et aucune donnée en cache'));
      } catch (e) {
        return Left(CacheFailure('Erreur lors de la récupération du cache: ${e.toString()}'));
      }
    }
  }

  @override
  Future<Either<Failure, List<Pharmacy>>> getNearestPharmacies({
    required double latitude,
    required double longitude,
    double radius = 10.0,
  }) async {
    // Pour l'instant, toujours utiliser les données factices
    try {
      final remotePharmacies = await remoteDataSource.getNearestPharmacies(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );
      await localDataSource.cachePharmacies(remotePharmacies);
      return Right(remotePharmacies);
    } catch (e) {
      // En cas d'erreur, essayer le cache
      try {
        final localPharmacies = await localDataSource.getCachedPharmacies();
        if (localPharmacies.isNotEmpty) {
          return Right(localPharmacies);
        }
      } catch (_) {
        // Ignorer les erreurs de cache
      }
      return Left(ServerFailure('Erreur lors de la récupération des pharmacies: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Pharmacy>>> getPharmaciesOnDuty({
    required double latitude,
    required double longitude,
    double radius = 10.0,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final remotePharmacies = await remoteDataSource.getPharmaciesOnDuty(
          latitude: latitude,
          longitude: longitude,
          radius: radius,
        );
        return Right(remotePharmacies);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('Erreur inattendue: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('Pas de connexion internet'));
    }
  }

  @override
  Future<Either<Failure, Pharmacy>> getPharmacyById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final remotePharmacy = await remoteDataSource.getPharmacyById(id);
        return Right(remotePharmacy);
      } on NotFoundException catch (e) {
        return Left(NotFoundFailure(e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('Erreur inattendue: ${e.toString()}'));
      }
    } else {
      try {
        final localPharmacy = await localDataSource.getCachedPharmacyById(id);
        if (localPharmacy != null) {
          return Right(localPharmacy);
        }
        return const Left(NotFoundFailure('Pharmacie non trouvée'));
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      } catch (e) {
        return Left(CacheFailure('Erreur lors de la récupération du cache: ${e.toString()}'));
      }
    }
  }
}

