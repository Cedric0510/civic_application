import 'package:civic_app/features/appointments/presentation/widgets/appointment_form.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppointmentPage extends StatelessWidget {
  const AppointmentPage({super.key});

  static const Color _headerColor = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 80,
            pinned: true,
            backgroundColor: _headerColor,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/home'),
            ),
            flexibleSpace: const FlexibleSpaceBar(
              title: Text(
                'Rendez-vous',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              titlePadding: EdgeInsets.only(left: 56, bottom: 12),
              background: ColoredBox(color: _headerColor),
            ),
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
