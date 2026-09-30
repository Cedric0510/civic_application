import 'package:civic_app/core/theme/feature_colors.dart';
import 'package:civic_app/shared/widgets/empty_state_message.dart';
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
              icon: Icons.location_city_outlined,
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
                  ? const SliverFillRemaining(
                      child: Center(
                        child: EmptyStateMessage(
                          icon: Icons.location_city_outlined,
                          color: FeatureColors.services,
                          message: 'Aucun service disponible.',
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
