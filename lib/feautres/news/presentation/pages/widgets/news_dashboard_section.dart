// lib/feautres/news/presentation/widgets/news_dashboard_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/enitites/news_article.dart';
import '../../state/news_providers.dart';
import '../../state/news_state.dart';
import '../news_details_page.dart';


class NewsDashboardSection extends ConsumerStatefulWidget {
  const NewsDashboardSection({Key? key}) : super(key: key);

  @override
  ConsumerState<NewsDashboardSection> createState() =>
      _NewsDashboardSectionState();
}

class _NewsDashboardSectionState
    extends ConsumerState<NewsDashboardSection> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      final controller = ref.read(newsControllerProvider.notifier);
      final state = ref.read(newsControllerProvider);

      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 200 &&
          state.status != NewsStatus.loadingMore &&
          state.hasMore) {
        controller.loadMore();
      }
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(newsControllerProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newsControllerProvider);

    if (state.status == NewsStatus.loading && state.articles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == NewsStatus.error && state.articles.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'News',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            state.errorMessage ?? 'Failed to load news.',
            style: const TextStyle(color: Colors.red),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Latest News',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            if (state.fromCache && state.offlineSince != null)
              Text(
                'Showing offline data from '
                    '${state.offlineSince!.toLocal().toString().substring(0, 16)}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 220,
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: state.articles.length +
                  (state.status == NewsStatus.loadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= state.articles.length) {
                  return const SizedBox(
                    width: 60,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final article = state.articles[index];
                return _NewsCard(
                  article: article,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            NewsDetailsPage(article: article),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class _NewsCard extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback onTap;

  const _NewsCard({
    Key? key,
    required this.article,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final thumbnail = article.imageUrl.isNotEmpty
        ? NetworkImage(article.imageUrl)
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).cardColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (thumbnail != null)
              ClipRRect(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image(
                  image: thumbnail,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
                  color: Colors.grey.shade300,
                ),
                child: const Center(
                  child: Icon(Icons.image_not_supported),
                ),
              ),
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.sourceName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(article.publishedAt),
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }
}