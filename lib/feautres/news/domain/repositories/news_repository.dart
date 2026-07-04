// lib/feautres/news/domain/repositories/news_repository.dart

import '../enitites/news_article.dart';
//import '../entities/news_article.dart';

abstract class NewsRepository {
  Future<NewsResult> getTopHeadlines({
    required int page,
    int pageSize,
    bool forceRemote,
  });

  Future<NewsResult> getMoreTopHeadlines({
    required int page,
    int pageSize,
  });

  Future<List<NewsArticle>> getBookmarks();
  Future<void> addBookmark(NewsArticle article);
  Future<void> removeBookmark(NewsArticle article);

  Future<NewsCache?> getLastCached();
}

class NewsResult {
  final List<NewsArticle> articles;
  final bool hasMore;
  final bool fromCache;

  NewsResult({
    required this.articles,
    required this.hasMore,
    required this.fromCache,
  });
}

class NewsCache {
  final List<NewsArticle> articles;
  final DateTime cachedAt;

  NewsCache({
    required this.articles,
    required this.cachedAt,
  });
}