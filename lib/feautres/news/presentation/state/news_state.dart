// lib/feautres/news/presentation/state/news_state.dart

import '../../domain/enitites/news_article.dart';


enum NewsStatus {
  initial,
  loading,
  loaded,
  loadingMore,
  refreshing,
  error,
}

class NewsState {
  final NewsStatus status;
  final List<NewsArticle> articles;
  final int currentPage;
  final bool hasMore;
  final bool fromCache;
  final String? errorMessage;
  final DateTime? offlineSince;

  const NewsState({
    this.status = NewsStatus.initial,
    this.articles = const [],
    this.currentPage = 1,
    this.hasMore = true,
    this.fromCache = false,
    this.errorMessage,
    this.offlineSince,
  });

  NewsState copyWith({
    NewsStatus? status,
    List<NewsArticle>? articles,
    int? currentPage,
    bool? hasMore,
    bool? fromCache,
    String? errorMessage,
    DateTime? offlineSince,
  }) {
    return NewsState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      fromCache: fromCache ?? this.fromCache,
      errorMessage: errorMessage,
      offlineSince: offlineSince,
    );
  }
}