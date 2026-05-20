import 'package:equatable/equatable.dart';

class Article extends Equatable {
  const Article({
    required this.id,
    required this.title,
    required this.content,
    required this.publishedAt,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String content;
  final String? imageUrl;
  final DateTime publishedAt;

  @override
  List<Object?> get props => [id, title, content, imageUrl, publishedAt];
}
