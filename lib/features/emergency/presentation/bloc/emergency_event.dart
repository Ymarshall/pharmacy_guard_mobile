import 'package:equatable/equatable.dart';

abstract class EmergencyEvent extends Equatable {
  const EmergencyEvent();

  @override
  List<Object> get props => [];
}

class GetEmergencyNumbersEvent extends EmergencyEvent {
  const GetEmergencyNumbersEvent();
}

