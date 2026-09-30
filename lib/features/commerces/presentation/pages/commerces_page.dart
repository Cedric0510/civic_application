import 'package:civic_app/core/theme/feature_colors.dart';
import 'package:civic_app/shared/widgets/empty_state_message.dart';
import 'package:civic_app/shared/widgets/feature_app_bar.dart';
import 'package:civic_app/features/commerces/presentation/controllers/commerces_controller.dart';
import 'package:civic_app/features/commerces/presentation/widgets/commerce_card.dart';
import 'package:civic_app/shared/widgets/error_retry_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommercesPage extends ConsumerWidget {
  const CommercesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(commercesControllerProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(commercesControllerProvider),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            FeatureAppBar(
              title: 'Commerçants',
              color: FeatureColors.commerces,
              backPath: '/home',
              icon: Icons.storefront_outlined,
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
                  message: 'Impossible de charger les commerçants.',
                  onRetry: () => ref.invalidate(commercesControllerProvider),
                ),
              ),
              data: (commerces) => commerces.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(
                        child: EmptyStateMessage(
                          icon: Icons.storefront_outlined,
                          color: FeatureColors.commerces,
                          message: 'Aucun commerçant disponible.',
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList.builder(
                        itemCount: commerces.length,
                        itemBuilder: (context, index) =>
                            CommerceCard(commerce: commerces[index]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
