// lib/feautres/news/presentation/state/news_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../data/news_api_client.dart';
import '../../data/news_local_data_source.dart';
import '../../data/news_repository_impl.dart';
import '../../domain/enitites/news_article.dart';

import '../../domain/repositories/news_repository.dart';
import 'news_state.dart';
import 'news_controller.dart';

final newsApiClientProvider = Provider<NewsApiClient>((ref) {
  return NewsApiClient();
});

final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  final apiClient = ref.watch(newsApiClientProvider);
  final cacheBox = Hive.box<NewsArticle>('news_cache_box');
  final bookmarksBox = Hive.box<NewsArticle>('news_bookmarks_box');

  final local = NewsLocalDataSource(
    cacheBox: cacheBox,
    bookmarksBox: bookmarksBox,
  );

  return NewsRepositoryImpl(
    apiClient: apiClient,
    localDataSource: local,
  );
});

final newsControllerProvider =
StateNotifierProvider<NewsController, NewsState>((ref) {
  final repo = ref.watch(newsRepositoryProvider);
  return NewsController(repository: repo)..loadInitial();
});

final bookmarksProvider =
FutureProvider<List<NewsArticle>>((ref) async {
  final repo = ref.watch(newsRepositoryProvider);
  return repo.getBookmarks();
});