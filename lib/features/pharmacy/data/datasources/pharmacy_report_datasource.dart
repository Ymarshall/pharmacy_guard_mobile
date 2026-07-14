import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';

abstract class PharmacyReportDataSource {
  Future<void> reportDutyIssue({
    required int pharmacyId,
    required int clientId,
  });
}

class PharmacyReportDataSourceImpl implements PharmacyReportDataSource {
  final ApiClient apiClient;

  PharmacyReportDataSourceImpl(this.apiClient);

  @override
  Future<void> reportDutyIssue({
    required int pharmacyId,
    required int clientId,
  }) async {
    try {
      final payload = {
        'pharmacyId': pharmacyId,
        'clientId': clientId,
      };
      
      // Log du payload
      print('🔴 [REPORT DUTY] Endpoint: ${ApiConstants.reportDutyEndpoint}');
      print('🔴 [REPORT DUTY] Payload: $payload');
      print('🔴 [REPORT DUTY] pharmacyId: $pharmacyId (type: ${pharmacyId.runtimeType})');
      print('🔴 [REPORT DUTY] clientId: $clientId (type: ${clientId.runtimeType})');
      
      await apiClient.post(
        ApiConstants.reportDutyEndpoint,
        body: payload,
      );
      
      print('✅ [REPORT DUTY] Signalement envoyé avec succès');
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Erreur lors du signalement: ${e.toString()}');
    }
  }
}
