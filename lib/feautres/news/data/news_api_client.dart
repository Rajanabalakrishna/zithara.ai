

// lib/feautres/news/data/news_api_client.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../domain/enitites/news_article.dart';



class NewsApiClient {
  final http.Client _client;

  static const _baseUrl = 'https://newsapi.org/v2/top-headlines';

  NewsApiClient({http.Client? client}) : _client = client ?? http.Client();

  String get _apiKey {
    final key = dotenv.env['API_KEY'];
    if (key == null || key.isEmpty) {
      throw StateError(
        'API_KEY is missing. Create assets/env/.env with API_KEY=your_key.',
      );
    }
    return key;
  }

  Future<NewsApiResponse> fetchTopHeadlines({
    required int page,
    int pageSize = 20,
    String country = 'in',
    String category = 'general',
  }) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'apiKey': _apiKey,
      'page': '$page',
      'pageSize': '$pageSize',
      'country': country,
      'category': category,
    });

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw NewsApiException(
        statusCode: response.statusCode,
        body: response.body,
      );
    }

    final Map<String, dynamic> jsonBody = jsonDecode(response.body);
    final List<dynamic> articlesJson =
        jsonBody['articles'] as List<dynamic>? ?? [];

    final articles = articlesJson.map((raw) {
      final map = raw as Map<String, dynamic>;
      final source = map['source'] as Map<String, dynamic>? ?? {};
      final url = map['url'] as String? ?? '';
      final publishedString = map['publishedAt'] as String? ?? '';

      DateTime publishedAt;
      try {
        publishedAt = DateTime.parse(publishedString).toLocal();
      } catch (_) {
        publishedAt = DateTime.now();
      }

      final id = '${url}_$publishedString';

      return NewsArticle(
        id: id,
        title: map['title'] as String? ?? '',
        description: map['description'] as String? ?? '',
        url: url,
        imageUrl: map['urlToImage'] as String? ?? '',
        sourceName: source['name'] as String? ?? '',
        publishedAt: publishedAt,
      );
    }).toList();

    final totalResults = jsonBody['totalResults'] as int? ?? articles.length;
    final hasMore = page * pageSize < totalResults;

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