import 'package:equatable/equatable.dart';

class SlotsQuery extends Equatable {
  const SlotsQuery({
    required this.serviceId,
    required this.from,
    required this.to,
  });

  final String serviceId;
  final DateTime from;
  final DateTime to;

  @override
  List<Object?> get props => [serviceId, from, to];
}
