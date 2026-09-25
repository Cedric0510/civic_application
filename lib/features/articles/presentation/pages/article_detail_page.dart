import 'package:civic_app/core/theme/feature_colors.dart';
import 'package:civic_app/shared/widgets/feature_app_bar.dart';
import 'package:civic_app/features/articles/presentation/controllers/articles_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ArticleDetailPage extends ConsumerWidget {
  const ArticleDetailPage({super.key, required this.articleId});

  final String articleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(articleDetailProvider(articleId));
    ref.watch(articleViewProvider(articleId));

    return Scaffold(
      body: state.when(
        loading: () => CustomScrollView(
          slivers: [
            _buildAppBar(context, null),
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  semanticsLabel: 'Chargement en cours',
                ),
              ),
            ),
          ],
        ),
        error: (error, stackTrace) => CustomScrollView(
          slivers: [
            _buildAppBar(context, null),
            const SliverFillRemaining(
              child: Center(child: Text('Impossible de charger l\'article.')),
            ),
          ],
        ),
        data: (article) => CustomScrollView(
          slivers: [
            _buildAppBar(context, article.imageUrl),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('dd/MM/yyyy').format(article.publishedAt),
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                        if (article.category != null) ...[
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: FeatureColors.articles.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              article.category!,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: FeatureColors.articles,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      article.content,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(height: 1.6),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, String? imageUrl) {
    return FeatureAppBar(
      title: 'Article',
      color: FeatureColors.articles,
      backPath: '/articles',
      expandedHeight: imageUrl != null ? 240 : 80,
      background: imageUrl != null
          ? Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  excludeFromSemantics: true,
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const ColoredBox(color: FeatureColors.articles),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.5),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ],
            )
          : const ColoredBox(color: FeatureColors.articles),
    );
  }
}
