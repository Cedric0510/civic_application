import 'package:civic_app/features/home/presentation/widgets/latest_articles_section.dart';
import 'package:civic_app/features/home/presentation/widgets/village_name_widget.dart';
import 'package:civic_app/features/home/presentation/widgets/weather_section.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('City-Co')),
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
