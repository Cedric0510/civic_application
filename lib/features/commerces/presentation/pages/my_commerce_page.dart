import 'package:civic_app/features/commerces/presentation/controllers/my_commerce_controller.dart';
import 'package:civic_app/features/commerces/presentation/widgets/my_commerce_form.dart';
import 'package:civic_app/shared/widgets/error_retry_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MyCommercePage extends ConsumerWidget {
  const MyCommercePage({super.key});

  static const Color _headerColor = Color(0xFF00897B);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commerceAsync = ref.watch(myCommerceProvider);

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
                'Mon commerce',
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
          commerceAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
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
