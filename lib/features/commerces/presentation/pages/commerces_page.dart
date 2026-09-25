import 'package:civic_app/core/theme/feature_colors.dart';
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
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.storefront_outlined,
                              size: 64,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucun commerçant disponible.',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ],
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
