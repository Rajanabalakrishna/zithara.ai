

// lib/feautres/news/presentation/pages/bookmarks_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../state/news_providers.dart';
import 'news_details_page.dart';

class BookmarksPage extends ConsumerWidget {
  const BookmarksPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(bookmarksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
      ),
      body: bookmarksAsync.when(
        data: (articles) {
          if (articles.isEmpty) {
            return const Center(child: Text('No bookmarks yet.'));
          }

          return ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return ListTile(
                leading: article.imageUrl.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    article.imageUrl,
                    height: 48,
                    width: 48,
                    fit: BoxFit.cover,
                  ),
                )
                    : const Icon(Icons.bookmark),
                title: Text(article.title),
                subtitle: Text(article.sourceName),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => NewsDetailsPage(article: article),
                    ),
                  );
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await ref
                        .read(newsRepositoryProvider)
                        .removeBookmark(article);
                    ref.refresh(bookmarksProvider);
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Failed to load bookmarks: $error')),
      ),
    );
  }
}