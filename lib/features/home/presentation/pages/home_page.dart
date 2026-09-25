import 'package:civic_app/features/home/presentation/widgets/articles_carousel.dart';
import 'package:civic_app/features/home/presentation/widgets/feedback_prompt_card.dart';
import 'package:civic_app/features/home/presentation/widgets/navigation_tiles_grid.dart';
import 'package:civic_app/features/home/presentation/widgets/village_name_widget.dart';
import 'package:civic_app/features/home/presentation/widgets/weather_section.dart';
import 'package:civic_app/features/settings/domain/entities/app_module.dart';
import 'package:civic_app/shared/widgets/module_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
              icon: const Icon(Icons.account_circle_outlined),
              tooltip: 'Mon compte',
              onPressed: () => context.go('/account'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const ModuleGate(
              module: AppModule.articles,
              child: ArticlesCarousel(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const VillageNameWidget(),
                  const SizedBox(height: 16),
                  const NavigationTilesGrid(),
                  const SizedBox(height: 16),
                  const ModuleGate(
                    module: AppModule.weather,
                    child: WeatherSection(),
                  ),
                  const SizedBox(height: 16),
                  const FeedbackPromptCard(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
