import 'package:hive/hive.dart';

part 'news_article.g.dart';

@HiveType(typeId: 1)
class NewsArticle extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String url;

  @HiveField(4)
  final String imageUrl;

  @HiveField(5)
  final String sourceName;

  @HiveField(6)
  final DateTime publishedAt;

  NewsArticle({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.imageUrl,
    required this.sourceName,
    required this.publishedAt,
  });

  NewsArticle copyWith({
    String? id,
    String? title,
    String? description,
    String? url,
    String? imageUrl,
    String? sourceName,
    DateTime? publishedAt,
  }) {
    return NewsArticle(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      url: url ?? this.url,
      imageUrl: imageUrl ?? this.imageUrl,
      sourceName: sourceName ?? this.sourceName,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }

  NewsArticle clone() {
    return NewsArticle(
      id: id,
      title: title,
      description: description,
      url: url,
      imageUrl: imageUrl,
      sourceName: sourceName,
      publishedAt: publishedAt,
    );
  }
}