import 'package:flutter/widgets.dart';

const double comfortTextFactor = 1.3;
const double maxTextScale = 2.0;

double comfortTextScale(double systemScale) =>
    (systemScale * comfortTextFactor).clamp(comfortTextFactor, maxTextScale);

class ComfortTextScale extends StatelessWidget {
  const ComfortTextScale({
    super.key,
    required this.comfort,
    required this.child,
  });

  final bool comfort;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!comfort) return child;
    final media = MediaQuery.of(context);
    final systemScale = media.textScaler.scale(16) / 16;
    return MediaQuery(
      data: media.copyWith(
        textScaler: TextScaler.linear(comfortTextScale(systemScale)),
      ),
      child: child,
    );
  }
}

bool usesLargeText(BuildContext context) =>
    MediaQuery.textScalerOf(context).scale(16) / 16 >= comfortTextFactor;
