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
      final cacheCopy = article.clone();
      await _cacheBox.put(cacheCopy.id, cacheCopy);
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
        .map((article) => article.clone())
        .toList();

    if (articles.isEmpty) return null;

    final timestampHolder = _cacheBox.get('_cached_at_');
    final cachedAt = timestampHolder?.publishedAt ?? DateTime.now();

    return NewsCache(
      articles: articles,
      cachedAt: cachedAt,
    );
  }

  Future<void> addBookmark(NewsArticle article) async {
    final bookmarkCopy = article.clone();
    await _bookmarksBox.put(bookmarkCopy.id, bookmarkCopy);
  }

  Future<void> removeBookmark(NewsArticle article) async {
    await _bookmarksBox.delete(article.id);
  }

  List<NewsArticle> getBookmarks() {
    return _bookmarksBox.values
        .map((article) => article.clone())
        .toList()
        .reversed
        .toList();
  }

  bool isBookmarked(String articleId) {
    return _bookmarksBox.containsKey(articleId);
  }

  Future<void> clearBookmarks() async {
    await _bookmarksBox.clear();
  }

  Future<void> clearCache() async {
    await _cacheBox.clear();
  }
}