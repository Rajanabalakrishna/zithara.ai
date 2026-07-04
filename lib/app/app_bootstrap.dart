import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../feautres/news/domain/enitites/news_article.dart';

Future<void> bootstrapApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: 'assets/env/.env');

  final appDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDir.path);

  if (!Hive.isAdapterRegistered(10)) {
    Hive.registerAdapter(NewsArticleAdapter());
  }

  if (!Hive.isBoxOpen('news_cache_box')) {
    await Hive.openBox<NewsArticle>('news_cache_box');
  }

  if (!Hive.isBoxOpen('news_bookmarks_box')) {
    await Hive.openBox<NewsArticle>('news_bookmarks_box');
  }
}