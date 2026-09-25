import 'package:civic_app/core/theme/feature_colors.dart';
import 'package:civic_app/shared/widgets/feature_app_bar.dart';
import 'package:civic_app/features/articles/presentation/controllers/articles_controller.dart';
import 'package:civic_app/features/articles/presentation/widgets/article_card.dart';
import 'package:civic_app/shared/widgets/error_retry_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ArticlesPage extends ConsumerStatefulWidget {
  const ArticlesPage({super.key});

  @override
  ConsumerState<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends ConsumerState<ArticlesPage> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(articlesControllerProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(articlesControllerProvider),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            FeatureAppBar(
              title: 'Actualités',
              color: FeatureColors.articles,
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
                  message: 'Impossible de charger les articles.',
                  onRetry: () => ref.invalidate(articlesControllerProvider),
                ),
              ),
              data: (articles) {
                final categories =
                    articles
                        .map((article) => article.category)
                        .whereType<String>()
                        .toSet()
                        .toList()
                      ..sort();
                final filtered = _selectedCategory == null
                    ? articles
                    : articles
                          .where(
                            (article) => article.category == _selectedCategory,
                          )
                          .toList();

                if (articles.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: Text('Aucun article disponible.')),
                  );
                }

                return SliverMainAxisGroup(
                  slivers: [
                    if (categories.isNotEmpty)
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 44,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                            itemCount: categories.length + 1,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final label = index == 0
                                  ? 'Toutes'
                                  : categories[index - 1];
                              final selected = index == 0
                                  ? _selectedCategory == null
                                  : _selectedCategory == categories[index - 1];
                              return ChoiceChip(
                                label: Text(label),
                                selected: selected,
                                onSelected: (_) => setState(() {
                                  _selectedCategory = index == 0
                                      ? null
                                      : categories[index - 1];
                                }),
                              );
                            },
                          ),
                        ),
                      ),
                    if (filtered.isEmpty)
                      const SliverFillRemaining(
                        child: Center(
                          child: Text('Aucun article dans cette catégorie.'),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverList.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) => ArticleCard(
                            article: filtered[index],
                            onTap: () =>
                                context.push('/articles/${filtered[index].id}'),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
