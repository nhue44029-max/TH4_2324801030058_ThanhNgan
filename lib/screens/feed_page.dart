import 'package:flutter/material.dart';

import '../models/article.dart';
import '../services/rss_service.dart';
import '../theme/app_theme.dart';
import '../widgets/article_card.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({
    super.key,
    required this.service,
    required this.feedUrl,
    required this.onArticle,
    required this.title,
    this.limit,
    this.intro = true,
  });
  final RssService service;
  final String feedUrl;
  final ValueChanged<Article> onArticle;
  final String title;
  final int? limit;
  final bool intro;

  @override
  State<FeedPage> createState() => FeedPageState();
}

class FeedPageState extends State<FeedPage> {
  List<Article> _articles = [];
  bool _loading = true;
  String? _error;
  int _request = 0;
  DateTime? _updatedAt;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  @override
  void didUpdateWidget(FeedPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.feedUrl != widget.feedUrl) {
      _articles = [];
      _updatedAt = null;
      refresh();
    }
  }

  Future<void> refresh() async {
    final request = ++_request;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final articles = await widget.service.fetch(
        widget.feedUrl,
        limit: widget.limit,
      );
      if (!mounted || request != _request) return;
      setState(() {
        _articles = articles;
        _updatedAt = DateTime.now();
      });
    } catch (error) {
      if (!mounted || request != _request) return;
      setState(
        () => _error = error is FeedException
            ? error.message
            : 'Chưa tải được tin. Vui lòng thử lại.',
      );
    } finally {
      if (mounted && request == _request) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasArticles = _articles.isNotEmpty;
    return RefreshIndicator(
      onRefresh: refresh,
      child: CustomScrollView(
        key: PageStorageKey(widget.feedUrl),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 12),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.intro) ...[
                    _IntroBanner(latest: widget.limit != null),
                    const SizedBox(height: 26),
                  ],
                  Row(
                    children: [
                      Container(
                        width: 5,
                        height: 23,
                        decoration: BoxDecoration(
                          color: widget.limit == null
                              ? AppColors.coral
                              : AppColors.teal,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (hasArticles)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: .09),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_articles.length} tin',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    _updatedAt == null
                        ? 'Tin tức từ VnExpress, cập nhật mỗi ngày'
                        : 'Vừa cập nhật lúc ${_updatedAt!.hour.toString().padLeft(2, '0')}:'
                              '${_updatedAt!.minute.toString().padLeft(2, '0')} · Nguồn VnExpress',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_loading && hasArticles)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: LinearProgressIndicator(minHeight: 2),
              ),
            ),
          if (_error != null && hasArticles)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chưa thể làm mới',
                          style: TextStyle(
                            color: colors.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('$_error Các tin bên dưới là lần tải trước.'),
                        TextButton.icon(
                          onPressed: _loading ? null : refresh,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (!hasArticles && _loading)
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        CircularProgressIndicator(strokeWidth: 3),
                        SizedBox(height: 14),
                        Text('Đang tải bản tin…'),
                      ],
                    ),
                  ),
                  for (var i = 0; i < 3; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 6,
                      ),
                      child: Card(
                        child: SizedBox(
                          height: 106,
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _SkeletonLine(
                                        color: colors.outlineVariant,
                                      ),
                                      const SizedBox(height: 10),
                                      FractionallySizedBox(
                                        widthFactor: .65,
                                        child: _SkeletonLine(
                                          color: colors.outlineVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 22),
                                Container(
                                  width: 84,
                                  decoration: BoxDecoration(
                                    color: colors.outlineVariant,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          if (!hasArticles && !_loading)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyState(error: _error, onRetry: refresh),
            ),
          if (hasArticles)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
              sliver: SliverList.separated(
                itemCount: _articles.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) => ArticleCard(
                  key: ValueKey('article-$index'),
                  article: _articles[index],
                  index: index,
                  onTap: () => widget.onArticle(_articles[index]),
                ),
              ),
            ),
          if (hasArticles)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Text(
                  widget.limit == null
                      ? 'Bạn đã xem hết bản tin. Hẹn bạn ở lần cập nhật tiếp theo.'
                      : 'Bạn đã xem hết ${_articles.length} tin mới nhất.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _IntroBanner extends StatelessWidget {
  const _IntroBanner({required this.latest});
  final bool latest;
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: dark
              ? [const Color(0xFF322745), const Color(0xFF222D40)]
              : [
                  const Color(0xFFFFECEF),
                  const Color(0xFFF0EBFF),
                  const Color(0xFFE9F8FA),
                ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  latest ? 'CẬP NHẬT LIÊN TỤC' : 'MỞ TIN TỨC · MỞ GÓC NHÌN',
                  style: TextStyle(
                    color: colors.primary,
                    fontSize: 10,
                    letterSpacing: 1.25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  latest
                      ? 'Bắt nhịp từng khoảnh khắc.'
                      : 'Thế giới hôm nay có gì?',
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.65,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  latest
                      ? '10 tin mới nhất, gói gọn trong một nơi.'
                      : 'Một chút tin, thêm nhiều điều mới.',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 49,
            height: 49,
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: .75),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(
              latest ? Icons.bolt_rounded : Icons.wb_sunny_rounded,
              color: latest ? colors.primary : const Color(0xFFBF7100),
              size: 29,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    height: 12,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(5),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({this.error, required this.onRetry});
  final String? error;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            error == null ? Icons.inbox_rounded : Icons.wifi_off_rounded,
            size: 54,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 18),
          Text(
            error == null
                ? 'Bản tin đang chờ cập nhật'
                : 'Chưa kết nối được bản tin',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Text(
            error ?? 'Nguồn RSS hiện chưa có bài viết. Bạn có thể tải lại sau.',
            textAlign: TextAlign.center,
            style: TextStyle(
              height: 1.6,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    ),
  );
}
