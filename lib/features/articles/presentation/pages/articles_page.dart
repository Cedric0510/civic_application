import 'package:civic_app/features/articles/presentation/controllers/articles_controller.dart';
import 'package:civic_app/features/articles/presentation/widgets/article_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ArticlesPage extends ConsumerWidget {
  const ArticlesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(articlesControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Actualités')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            const Center(child: Text('Impossible de charger les articles.')),
        data: (articles) => articles.isEmpty
            ? const Center(child: Text('Aucun article disponible.'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: articles.length,
                itemBuilder: (context, index) => ArticleCard(
                  article: articles[index],
                  onTap: () => context.push('/articles/${articles[index].id}'),
                ),
              ),
      ),
    );
  }
}
