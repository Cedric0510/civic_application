import 'package:equatable/equatable.dart';

class CitySettings extends Equatable {
  const CitySettings({required this.villageName});

  final String villageName;

  @override
  List<Object?> get props => [villageName];
}
