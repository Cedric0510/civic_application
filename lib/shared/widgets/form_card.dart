import 'package:flutter/material.dart';

class FormCard extends StatelessWidget {
  const FormCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    );
  }
}
