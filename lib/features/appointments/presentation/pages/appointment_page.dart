import 'package:civic_app/features/appointments/presentation/widgets/appointment_form.dart';
import 'package:flutter/material.dart';

class AppointmentPage extends StatelessWidget {
  const AppointmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prendre rendez-vous')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: AppointmentForm(),
      ),
    );
  }
}
