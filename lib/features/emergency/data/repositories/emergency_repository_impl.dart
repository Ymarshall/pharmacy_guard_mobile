import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/emergency_number.dart';
import '../../domain/repositories/emergency_repository.dart';
import '../datasources/emergency_remote_datasource.dart';
import '../datasources/emergency_local_datasource.dart';

class EmergencyRepositoryImpl implements EmergencyRepository {
  final EmergencyRemoteDataSource remoteDataSource;
  final EmergencyLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  EmergencyRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<EmergencyNumber>>> getEmergencyNumbers() async {
    final isConnected = await networkInfo.isConnected;
    
    if (isConnected) {
      try {
        // Tenter de récupérer depuis l'API
        final remoteNumbers = await remoteDataSource.getEmergencyNumbers();
        
        // Mettre en cache les données récupérées
        await localDataSource.cacheEmergencyNumbers(remoteNumbers);
        
        // Retourner les données de l'API
        return Right(remoteNumbers);
      } on ServerException catch (e) {
        // En cas d'erreur serveur, essayer le cache
        try {
          final cachedNumbers = await localDataSource.getCachedEmergencyNumbers();
          // Retourner les données du cache (mais on ne peut pas indiquer que c'est du cache)
          return Right(cachedNumbers);
        } catch (cacheError) {
          return Left(ServerFailure(e.message));
        }
      } on NetworkException catch (e) {
        // En cas d'erreur réseau, essayer le cache
        try {
          final cachedNumbers = await localDataSource.getCachedEmergencyNumbers();
          return Right(cachedNumbers);
        } catch (cacheError) {
          return Left(NetworkFailure(e.message));
        }
      } catch (e) {
        // En cas d'erreur inattendue, essayer le cache
        try {
          final cachedNumbers = await localDataSource.getCachedEmergencyNumbers();
          return Right(cachedNumbers);
        } catch (cacheError) {
          return Left(ServerFailure('Erreur inattendue: ${e.toString()}'));
        }
      }
    } else {
      // Pas de connexion internet, utiliser le cache
      try {
        final cachedNumbers = await localDataSource.getCachedEmergencyNumbers();
        return Right(cachedNumbers);
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      } catch (e) {
        return Left(CacheFailure('Erreur lors de la récupération du cache: ${e.toString()}'));
      }
    }
  }
}
