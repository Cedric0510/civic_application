import 'package:civic_app/core/constants/app_constants.dart';
import 'package:civic_app/features/articles/presentation/controllers/articles_controller.dart';
import 'package:civic_app/features/articles/presentation/widgets/article_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LatestArticlesSection extends ConsumerWidget {
  const LatestArticlesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(articlesControllerProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Latest News',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Text(error.toString()),
          data: (articles) {
            final latestArticles = articles
                .take(AppConstants.homeArticlesCount)
                .toList();
            if (latestArticles.isEmpty) {
              return const Text('No articles available.');
            }
            return Column(
              children: latestArticles
                  .map(
                    (article) => ArticleCard(
                      article: article,
                      onTap: () => context.push('/articles/${article.id}'),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}
