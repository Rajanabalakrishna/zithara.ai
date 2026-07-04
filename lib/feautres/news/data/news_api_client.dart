import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../domain/enitites/news_article.dart';

class NewsApiClient {
  final http.Client _client;

  static const _baseUrl = 'https://newsapi.org/v2/top-headlines';
  static const _apiKey = '25caba64bf504b13b1c589658b95e191';

  NewsApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<NewsApiResponse> fetchTopHeadlines({
    required int page,
    int pageSize = 20,
    String country = 'us',
    String category = 'general',
  }) async {
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'apiKey': _apiKey,
        'page': '$page',
        'pageSize': '$pageSize',
        'country': country,
        'category': category,
      },
    );

    debugPrint('================ NEWS API DEBUG ================');
    debugPrint('API KEY: $_apiKey');
    debugPrint('REQUEST URI: $uri');
    debugPrint('PAGE: $page');
    debugPrint('PAGE SIZE: $pageSize');
    debugPrint('COUNTRY: $country');
    debugPrint('CATEGORY: $category');

    final response = await _client.get(uri);

    debugPrint('STATUS CODE: ${response.statusCode}');
    debugPrint('RESPONSE BODY: ${response.body}');
    debugPrint('===============================================');

    if (response.statusCode != 200) {
      throw NewsApiException(
        statusCode: response.statusCode,
        body: response.body,
      );
    }

    final Map<String, dynamic> jsonBody = jsonDecode(response.body);

    if (jsonBody['status'] != 'ok') {
      throw NewsApiException(
        statusCode: response.statusCode,
        body: response.body,
      );
    }

    final List<dynamic> articlesJson =
        jsonBody['articles'] as List<dynamic>? ?? [];

    final articles = articlesJson
        .map((raw) {
      final map = raw as Map<String, dynamic>;
      final source = map['source'] as Map<String, dynamic>? ?? {};
      final url = (map['url'] as String? ?? '').trim();
      final title = (map['title'] as String? ?? '').trim();
      final publishedString = (map['publishedAt'] as String? ?? '').trim();

      if (url.isEmpty || title.isEmpty) return null;

      DateTime publishedAt;
      try {
        publishedAt = DateTime.parse(publishedString).toLocal();
      } catch (_) {
        publishedAt = DateTime.now();
      }

      final id = '${url}_$publishedString';

      return NewsArticle(
        id: id,
        title: title,
        description: (map['description'] as String? ?? '').trim(),
        url: url,
        imageUrl: (map['urlToImage'] as String? ?? '').trim(),
        sourceName: (source['name'] as String? ?? 'Unknown').trim(),
        publishedAt: publishedAt,
      );
    })
        .whereType<NewsArticle>()
        .toList();

    final totalResults = jsonBody['totalResults'] as int? ?? articles.length;
    final hasMore = page * pageSize < totalResults;

    debugPrint('PARSED ARTICLES COUNT: ${articles.length}');
    debugPrint('TOTAL RESULTS: $totalResults');
    debugPrint('HAS MORE: $hasMore');

    return NewsApiResponse(
      articles: articles,
      hasMore: hasMore,
    );
  }
}

class NewsApiResponse {
  final List<NewsArticle> articles;
  final bool hasMore;

  NewsApiResponse({
    required this.articles,
    required this.hasMore,
  });
}

class NewsApiException implements Exception {
  final int statusCode;
  final String body;

  NewsApiException({
    required this.statusCode,
    required this.body,
  });

  @override
  String toString() => 'NewsApiException(statusCode: $statusCode, body: $body)';
}