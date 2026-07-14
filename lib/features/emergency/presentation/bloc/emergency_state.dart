import 'package:equatable/equatable.dart';
import '../../domain/entities/emergency_number.dart';

abstract class EmergencyState extends Equatable {
  const EmergencyState();

  @override
  List<Object> get props => [];
}

class EmergencyInitial extends EmergencyState {}

class EmergencyLoading extends EmergencyState {}

class EmergencyLoaded extends EmergencyState {
  final List<EmergencyNumber> emergencyNumbers;
  final bool isFromCache;

  const EmergencyLoaded({
    required this.emergencyNumbers,
    this.isFromCache = false,
  });

  @override
  List<Object> get props => [emergencyNumbers, isFromCache];
}

class EmergencyError extends EmergencyState {
  final String message;

  const EmergencyError(this.message);

  @override
  List<Object> get props => [message];
}

