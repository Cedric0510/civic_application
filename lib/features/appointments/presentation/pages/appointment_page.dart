import 'package:civic_app/core/theme/feature_colors.dart';
import 'package:civic_app/shared/widgets/feature_app_bar.dart';
import 'package:civic_app/features/appointments/presentation/widgets/appointment_form.dart';
import 'package:flutter/material.dart';

class AppointmentPage extends StatelessWidget {
  const AppointmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          FeatureAppBar(
            title: 'Rendez-vous',
            color: FeatureColors.appointments,
            backPath: '/home',
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: AppointmentForm(),
            ),
          ),
        ],
      ),
    );
  }
}
