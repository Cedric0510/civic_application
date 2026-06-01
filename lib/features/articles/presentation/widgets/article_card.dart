import 'package:civic_app/features/articles/domain/entities/article.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ArticleCard extends StatelessWidget {
  const ArticleCard({super.key, required this.article, required this.onTap});

  final Article article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 110,
          child: Row(
            children: [
              SizedBox(
                width: 110,
                child: article.imageUrl != null
                    ? Image.network(
                        article.imageUrl!,
                        fit: BoxFit.cover,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: colorScheme.outline,
                          ),
                        ),
                      )
                    : Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.article_outlined,
                          color: colorScheme.outline,
                          size: 36,
                        ),
                      ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        article.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 12,
                            color: colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat(
                              'dd/MM/yyyy',
                            ).format(article.publishedAt),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colorScheme.outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(Icons.chevron_right, color: colorScheme.outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
