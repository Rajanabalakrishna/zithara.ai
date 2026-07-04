// lib/feautres/news/presentation/pages/news_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/enitites/news_article.dart';
import '../state/news_controller.dart';
import '../state/news_providers.dart';
import '../state/news_state.dart';
import 'bookmarks_page.dart';
import 'news_details_page.dart';
import 'settings_page.dart';

class NewsTab extends ConsumerStatefulWidget {
  const NewsTab({Key? key}) : super(key: key);

  @override
  ConsumerState<NewsTab> createState() => _NewsTabState();
}

class _NewsTabState extends ConsumerState<NewsTab> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Tracks which sub-page to show inside this tab: 0=list, 1=bookmarks, 2=settings
  int _subPage = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final state = ref.read(newsControllerProvider);
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300 &&
        state.status != NewsStatus.loadingMore &&
        state.hasMore) {
      ref.read(newsControllerProvider.notifier).loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(newsControllerProvider.notifier).refresh();
  }

  void _navigate(int index) {
    setState(() => _subPage = index);
    Navigator.of(context).pop(); // Close drawer
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      key: _scaffoldKey,
      // ── Drawer with menu options ─────────────────────────────────
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drawer header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                color: colorScheme.primaryContainer,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.article_rounded,
                        size: 36, color: colorScheme.onPrimaryContainer),
                    const SizedBox(height: 12),
                    Text(
                      'News Hub',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      'Your daily digest',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Menu items
              _DrawerItem(
                icon: Icons.newspaper_rounded,
                label: 'Top Headlines',
                selected: _subPage == 0,
                onTap: () => _navigate(0),
              ),
              _DrawerItem(
                icon: Icons.bookmark_rounded,
                label: 'Bookmarks',
                selected: _subPage == 1,
                onTap: () => _navigate(1),
              ),
              _DrawerItem(
                icon: Icons.settings_rounded,
                label: 'Settings',
                selected: _subPage == 2,
                onTap: () => _navigate(2),
              ),
              const Spacer(),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'News & Weather Hub',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // ── AppBar ───────────────────────────────────────────────────
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          tooltip: 'Menu',
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(_tabTitle()),
        centerTitle: true,
        actions: [
          if (_subPage == 0)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh',
              onPressed: _onRefresh,
            ),
        ],
      ),

      // ── Body: switch between sub-pages ──────────────────────────
      body: IndexedStack(
        index: _subPage,
        children: [
          _NewsListBody(scrollController: _scrollController, onRefresh: _onRefresh),
          const BookmarksBody(),
          const SettingsBody(),
        ],
      ),
    );
  }

  String _tabTitle() {
    switch (_subPage) {
      case 1:
        return 'Bookmarks';
      case 2:
        return 'Settings';
      default:
        return 'Top Headlines';
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

// ── Drawer Item Widget ─────────────────────────────────────────────
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DrawerItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(
        icon,
        color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          color: selected ? colorScheme.primary : colorScheme.onSurface,
        ),
      ),
      selected: selected,
      selectedTileColor: colorScheme.primaryContainer.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      onTap: onTap,
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Sub-page 0: News list (Infinite scroll)
// ─────────────────────────────────────────────────────────────────
class _NewsListBody extends ConsumerWidget {
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;

  const _NewsListBody({
    Key? key,
    required this.scrollController,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(newsControllerProvider);

    // Initial loading
    if (state.status == NewsStatus.loading && state.articles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Hard error, no cache
    if (state.status == NewsStatus.error && state.articles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded,
                  size: 72, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Could not load news',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                state.errorMessage ?? 'Check your internet connection.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          // Offline banner
          if (state.fromCache && state.offlineSince != null)
            SliverToBoxAdapter(
              child: _OfflineBanner(offlineSince: state.offlineSince!),
            ),

          // Article list
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => _NewsCard(
                article: state.articles[index],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          NewsDetailsPage(article: state.articles[index]),
                    ),
                  );
                },
              ),
              childCount: state.articles.length,
            ),
          ),

          // Load more spinner
          if (state.status == NewsStatus.loadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),

          // End of list
          if (!state.hasMore && state.articles.isNotEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    "You're all caught up! 🎉",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  final DateTime offlineSince;
  const _OfflineBanner({Key? key, required this.offlineSince})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.orange.shade50,
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded,
              color: Colors.deepOrange, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Showing offline data from ${offlineSince.toLocal().toString().substring(0, 16)}',
              style: const TextStyle(
                  fontSize: 12, color: Colors.deepOrange),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback onTap;

  const _NewsCard({Key? key, required this.article, required this.onTap})
      : super(key: key);

  String _formatDate(DateTime dt) {
    final l = dt.toLocal();
    return '${l.year}-${l.month.toString().padLeft(2, '0')}-${l.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      color: colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: article.imageUrl.isNotEmpty
                    ? Image.network(
                  article.imageUrl,
                  width: 88,
                  height: 88,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _placeholder(colorScheme),
                )
                    : _placeholder(colorScheme),
              ),
              const SizedBox(width: 12),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            article.sourceName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          _formatDate(article.publishedAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder(ColorScheme cs) {
    return Container(
      width: 88,
      height: 88,
      color: cs.surfaceVariant,
      child:
      Icon(Icons.image_not_supported_outlined, color: cs.outline, size: 28),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Sub-page 1: Bookmarks (inline body, no Scaffold)
// ─────────────────────────────────────────────────────────────────
class BookmarksBody extends ConsumerWidget {
  const BookmarksBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(bookmarksProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return bookmarksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Failed to load: $e')),
      data: (articles) {
        if (articles.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bookmark_border_rounded,
                    size: 72, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text(
                  'No bookmarks yet',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the bookmark icon on any article to save it.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: colorScheme.onSurfaceVariant, fontSize: 13),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: articles.length,
          itemBuilder: (context, index) {
            final article = articles[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: article.imageUrl.isNotEmpty
                      ? Image.network(
                    article.imageUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Icon(Icons.bookmark_rounded,
                            color: colorScheme.primary, size: 36),
                  )
                      : Icon(Icons.bookmark_rounded,
                      color: colorScheme.primary, size: 36),
                ),
                title: Text(
                  article.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                ),
                subtitle: Text(
                  article.sourceName,
                  style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Colors.redAccent),
                  tooltip: 'Remove bookmark',
                  onPressed: () async {
                    await ref
                        .read(newsRepositoryProvider)
                        .removeBookmark(article);
                    ref.invalidate(bookmarksProvider);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Bookmark removed'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NewsDetailsPage(article: article),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Sub-page 2: Settings (inline body, no Scaffold)
// ─────────────────────────────────────────────────────────────────
class SettingsBody extends StatelessWidget {
  const SettingsBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionLabel(label: 'APPEARANCE'),
        Card(
          elevation: 0,
          color: colorScheme.surfaceVariant.withOpacity(0.4),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.light_mode_rounded),
                title: const Text('Light Mode'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {},
              ),
              Divider(
                  height: 1,
                  indent: 56,
                  color: colorScheme.outlineVariant.withOpacity(0.5)),
              ListTile(
                leading: const Icon(Icons.dark_mode_rounded),
                title: const Text('Dark Mode'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _SectionLabel(label: 'WEATHER PREFERENCES'),
        Card(
          elevation: 0,
          color: colorScheme.surfaceVariant.withOpacity(0.4),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            leading: const Icon(Icons.location_city_rounded),
            title: const Text('Default City'),
            subtitle: const Text('Set your preferred city for weather'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}