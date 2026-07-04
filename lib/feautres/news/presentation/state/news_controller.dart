import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/enitites/news_article.dart';
import '../../domain/repositories/news_repository.dart';
import 'news_state.dart';

class NewsController extends StateNotifier<NewsState> {
  final NewsRepository _repository;

  NewsController({required NewsRepository repository})
      : _repository = repository,
        super(const NewsState());

  Future<void> loadInitial() async {
    debugPrint('NEWS CONTROLLER: loadInitial() called');
    state = state.copyWith(status: NewsStatus.loading, currentPage: 1);

    try {
      final result = await _repository.getTopHeadlines(page: 1);
      debugPrint('NEWS CONTROLLER: loadInitial success');
      debugPrint('NEWS CONTROLLER: articles=${result.articles.length}');
      debugPrint('NEWS CONTROLLER: hasMore=${result.hasMore}');
      debugPrint('NEWS CONTROLLER: fromCache=${result.fromCache}');

      state = state.copyWith(
        status: NewsStatus.loaded,
        articles: result.articles,
        currentPage: 1,
        hasMore: result.hasMore,
        fromCache: result.fromCache,
        offlineSince: result.fromCache ? DateTime.now() : null,
        errorMessage: null,
      );
    } catch (e, st) {
      debugPrint('NEWS CONTROLLER ERROR in loadInitial: $e');
      debugPrint('$st');
      state = state.copyWith(
        status: NewsStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    debugPrint('NEWS CONTROLLER: loadMore() called');
    if (!state.hasMore || state.status == NewsStatus.loadingMore) return;

    final nextPage = state.currentPage + 1;
    state = state.copyWith(status: NewsStatus.loadingMore);

    try {
      final result = await _repository.getMoreTopHeadlines(page: nextPage);
      debugPrint('NEWS CONTROLLER: loadMore success, got=${result.articles.length}');

      state = state.copyWith(
        status: NewsStatus.loaded,
        currentPage: nextPage,
        articles: [...state.articles, ...result.articles],
        hasMore: result.hasMore,
        fromCache: false,
        offlineSince: null,
        errorMessage: null,
      );
    } catch (e, st) {
      debugPrint('NEWS CONTROLLER ERROR in loadMore: $e');
      debugPrint('$st');
      state = state.copyWith(
        status: NewsStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    debugPrint('NEWS CONTROLLER: refresh() called');
    state = state.copyWith(status: NewsStatus.refreshing);

    try {
      final result = await _repository.getTopHeadlines(page: 1, forceRemote: true);
      debugPrint('NEWS CONTROLLER: refresh success, got=${result.articles.length}');

      state = state.copyWith(
        status: NewsStatus.loaded,
        currentPage: 1,
        articles: result.articles,
        hasMore: result.hasMore,
        fromCache: result.fromCache,
        offlineSince: result.fromCache ? DateTime.now() : null,
        errorMessage: null,
      );
    } catch (e, st) {
      debugPrint('NEWS CONTROLLER ERROR in refresh: $e');
      debugPrint('$st');

      final cache = await _repository.getLastCached();
      if (cache != null) {
        state = state.copyWith(
          status: NewsStatus.loaded,
          articles: cache.articles,
          hasMore: false,
          fromCache: true,
          offlineSince: cache.cachedAt,
          errorMessage: e.toString(),
        );
      } else {
        state = state.copyWith(
          status: NewsStatus.error,
          errorMessage: e.toString(),
        );
      }
    }
  }

  Future<void> toggleBookmark(NewsArticle article) async {
    final bookmarks = await _repository.getBookmarks();
    final exists = bookmarks.any((a) => a.id == article.id);

    if (exists) {
      await _repository.removeBookmark(article);
    } else {
      await _repository.addBookmark(article);
    }
  }
}