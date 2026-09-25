import 'package:civic_app/core/theme/feature_colors.dart';
import 'package:civic_app/shared/widgets/feature_app_bar.dart';
import 'package:civic_app/features/services/presentation/controllers/services_controller.dart';
import 'package:civic_app/features/services/presentation/widgets/service_card.dart';
import 'package:civic_app/shared/widgets/error_retry_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ServicesPage extends ConsumerWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(servicesControllerProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(servicesControllerProvider),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            FeatureAppBar(
              title: 'Services',
              color: FeatureColors.services,
              backPath: '/home',
            ),
            state.when(
              loading: () => const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    semanticsLabel: 'Chargement en cours',
                  ),
                ),
              ),
              error: (error, stackTrace) => SliverFillRemaining(
                child: ErrorRetryWidget(
                  message: 'Impossible de charger les services.',
                  onRetry: () => ref.invalidate(servicesControllerProvider),
                ),
              ),
              data: (services) => services.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_city_outlined,
                              size: 64,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucun service disponible.',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList.builder(
                        itemCount: services.length,
                        itemBuilder: (context, index) =>
                            ServiceCard(service: services[index]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
