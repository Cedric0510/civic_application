import 'package:equatable/equatable.dart';

const String comfortModeName = 'Mode Confort';
const String comfortModeDescription =
    'Textes plus grands, contrastes renforcés et boutons plus faciles à toucher.';

class DisplaySettings extends Equatable {
  const DisplaySettings({this.comfortMode = false});

  final bool comfortMode;

  DisplaySettings copyWith({bool? comfortMode}) =>
      DisplaySettings(comfortMode: comfortMode ?? this.comfortMode);

  @override
  List<Object?> get props => [comfortMode];
}
