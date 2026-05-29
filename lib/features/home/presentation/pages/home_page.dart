import 'package:civic_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:civic_app/features/home/presentation/widgets/latest_articles_section.dart';
import 'package:civic_app/features/home/presentation/widgets/village_name_widget.dart';
import 'package:civic_app/features/home/presentation/widgets/weather_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('City-Co'),
        actions: [
          Consumer(
            builder: (context, ref, _) => IconButton(
              icon: const Icon(Icons.logout_outlined),
              tooltip: 'Se déconnecter',
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).signOut(),
            ),
          ),
        ],
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VillageNameWidget(),
            SizedBox(height: 24),
            WeatherSection(),
            SizedBox(height: 24),
            LatestArticlesSection(),
          ],
        ),
      ),
    );
  }
}
