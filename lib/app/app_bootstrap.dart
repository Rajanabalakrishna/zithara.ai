

// lib/app/app_bootstrap.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../feautres/news/domain/enitites/news_article.dart';


Future<void> bootstrapApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (NewsAPI key, etc.).
  await dotenv.load(fileName: 'assets/env/.env');

  final appDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDir.path);

  // Register adapters / open boxes for News feature.
  Hive.registerAdapter(NewsArticleAdapter());
  await Hive.openBox<NewsArticle>('news_cache_box');
  await Hive.openBox<NewsArticle>('news_bookmarks_box');

  // NOTE: keep your existing weather Hive setup separate and unchanged.
}