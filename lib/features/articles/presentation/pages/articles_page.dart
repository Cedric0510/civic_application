import 'package:civic_app/features/articles/presentation/controllers/articles_controller.dart';
import 'package:civic_app/features/articles/presentation/widgets/article_card.dart';
import 'package:civic_app/shared/widgets/error_retry_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ArticlesPage extends ConsumerWidget {
  const ArticlesPage({super.key});

  static const Color _headerColor = Color(0xFF1E88E5);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(articlesControllerProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(articlesControllerProvider),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                  'Actualités',
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
            state.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) => SliverFillRemaining(
                child: ErrorRetryWidget(
                  message: 'Impossible de charger les articles.',
                  onRetry: () => ref.invalidate(articlesControllerProvider),
                ),
              ),
              data: (articles) => articles.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(child: Text('Aucun article disponible.')),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList.builder(
                        itemCount: articles.length,
                        itemBuilder: (context, index) => ArticleCard(
                          article: articles[index],
                          onTap: () =>
                              context.push('/articles/${articles[index].id}'),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
