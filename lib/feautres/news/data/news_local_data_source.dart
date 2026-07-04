// lib/feautres/news/data/news_local_data_source.dart

import 'package:hive/hive.dart';

import '../domain/enitites/news_article.dart';

import '../domain/repositories/news_repository.dart';

class NewsLocalDataSource {
  final Box<NewsArticle> _cacheBox;
  final Box<NewsArticle> _bookmarksBox;

  NewsLocalDataSource({
    required Box<NewsArticle> cacheBox,
    required Box<NewsArticle> bookmarksBox,
  })  : _cacheBox = cacheBox,
        _bookmarksBox = bookmarksBox;

  Future<void> cacheArticles(List<NewsArticle> articles) async {
    await _cacheBox.clear();
    for (final article in articles) {
      await _cacheBox.put(article.id, article);
    }
    await _cacheBox.put(
      '_cached_at_',
      NewsArticle(
        id: '_cached_at_',
        title: '',
        description: '',
        url: '',
        imageUrl: '',
        sourceName: '',
        publishedAt: DateTime.now(),
      ),
    );
  }

  NewsCache? getLastCached() {
    if (_cacheBox.isEmpty) return null;

    final List<NewsArticle> articles = _cacheBox.values
        .where((article) => article.id != '_cached_at_')
        .toList();

    if (articles.isEmpty) return null;

    final timestampHolder = _cacheBox.get('_cached_at_');
    final cachedAt = timestampHolder?.publishedAt ?? DateTime.now();

    return NewsCache(
      articles: articles,
      cachedAt: cachedAt,
    );
  }

  Future<List<NewsArticle>> getBookmarks() async {
    return _bookmarksBox.values.toList();
  }

  Future<void> addBookmark(NewsArticle article) async {
    await _bookmarksBox.put(article.id, article);
  }

  Future<void> removeBookmark(NewsArticle article) async {
    await _bookmarksBox.delete(article.id);
  }
}