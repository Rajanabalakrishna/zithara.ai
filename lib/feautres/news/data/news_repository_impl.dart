// lib/feautres/news/data/news_repository_impl.dart

import '../domain/enitites/news_article.dart';

import '../domain/repositories/news_repository.dart';
import 'news_api_client.dart';
import 'news_local_data_source.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsApiClient _apiClient;
  final NewsLocalDataSource _localDataSource;

  NewsRepositoryImpl({
    required NewsApiClient apiClient,
    required NewsLocalDataSource localDataSource,
  })  : _apiClient = apiClient,
        _localDataSource = localDataSource;

  @override
  Future<NewsResult> getTopHeadlines({
    required int page,
    int pageSize = 20,
    bool forceRemote = false,
  }) async {
    try {
      final response = await _withRetries(
            () => _apiClient.fetchTopHeadlines(page: page, pageSize: pageSize),
      );

      if (page == 1) {
        await _localDataSource.cacheArticles(response.articles);
      }

      return NewsResult(
        articles: response.articles,
        hasMore: response.hasMore,
        fromCache: false,
      );
    } catch (_) {
      if (page == 1) {
        final cached = _localDataSource.getLastCached();
        if (cached != null) {
          return NewsResult(
            articles: cached.articles,
            hasMore: false,
            fromCache: true,
          );
        }
      }
      rethrow;
    }
  }

  @override
  Future<NewsResult> getMoreTopHeadlines({
    required int page,
    int pageSize = 20,
  }) async {
    final response = await _withRetries(
          () => _apiClient.fetchTopHeadlines(page: page, pageSize: pageSize),
    );

    return NewsResult(
      articles: response.articles,
      hasMore: response.hasMore,
      fromCache: false,
    );
  }

  Future<NewsApiResponse> _withRetries(
      Future<NewsApiResponse> Function() fn,
      ) async {
    const maxAttempts = 2;
    int attempt = 0;
    Object? lastError;

    while (attempt < maxAttempts) {
      try {
        attempt++;
        return await fn();
      } catch (e) {
        lastError = e;
        await Future.delayed(Duration(milliseconds: 600 * attempt));
      }
    }
    throw lastError ?? Exception('Unknown News API error');
  }

  @override
  Future<List<NewsArticle>> getBookmarks() async {
    return _localDataSource.getBookmarks();
  }

  @override
  Future<void> addBookmark(NewsArticle article) {
    return _localDataSource.addBookmark(article);
  }

  @override
  Future<void> removeBookmark(NewsArticle article) {
    return _localDataSource.removeBookmark(article);
  }

  @override
  Future<NewsCache?> getLastCached() async {
    return _localDataSource.getLastCached();
  }
}