import 'package:civic_app/core/theme/feature_colors.dart';
import 'package:civic_app/shared/widgets/feature_app_bar.dart';
import 'package:civic_app/features/commerces/presentation/controllers/my_commerce_controller.dart';
import 'package:civic_app/features/commerces/presentation/widgets/my_commerce_form.dart';
import 'package:civic_app/shared/widgets/error_retry_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyCommercePage extends ConsumerWidget {
  const MyCommercePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commerceAsync = ref.watch(myCommerceProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          FeatureAppBar(
            title: 'Mon commerce',
            color: FeatureColors.commerces,
            backPath: '/home',
          ),
          commerceAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  semanticsLabel: 'Chargement en cours',
                ),
              ),
            ),
            error: (error, stackTrace) => SliverFillRemaining(
              child: ErrorRetryWidget(
                message: 'Impossible de charger votre commerce.',
                onRetry: () => ref.invalidate(myCommerceProvider),
              ),
            ),
            data: (commerce) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: MyCommerceForm(commerce: commerce),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
