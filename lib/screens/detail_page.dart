import 'package:flutter/material.dart';

import '../models/article.dart';
import '../services/article_content_service.dart';
import '../widgets/article_card.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key, required this.article});

  final Article article;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final ArticleContentService _service = ArticleContentService();
  late Future<ArticleContent> _contentFuture;

  @override
  void initState() {
    super.initState();
    _contentFuture = _service.load(widget.article.url);
  }

  @override
  void didUpdateWidget(covariant DetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.article.url != widget.article.url) {
      _contentFuture = _service.load(widget.article.url);
    }
  }

  @override
  void dispose() {
    _service.close();
    super.dispose();
  }

  Future<void> _reload() async {
    final future = _service.load(widget.article.url);
    setState(() => _contentFuture = future);
    try {
      await future;
    } catch (_) {
      // FutureBuilder sẽ hiển thị lỗi và nút thử lại.
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ArticleContent>(
      future: _contentFuture,
      builder: (context, snapshot) {
        return RefreshIndicator(
          onRefresh: _reload,
          child: ListView(
            key: ValueKey('detail-${widget.article.url}'),
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 36),
            children: [
              ..._buildRssHeader(context),
              const SizedBox(height: 26),
              Text(
                'Nội dung bài báo',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              if (snapshot.connectionState == ConnectionState.waiting)
                const _LoadingContent()
              else if (snapshot.hasError)
                _LoadError(onRetry: _reload)
              else
                ..._buildFullContent(context, snapshot.data!),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildRssHeader(BuildContext context) {
    final article = widget.article;
    final colors = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return [
      Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'VnExpress',
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'TIN TỪ RSS VNEXPRESS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      SelectableText(
        article.title,
        key: const ValueKey('detail-title'),
        style: TextStyle(
          fontSize: screenWidth >= 700 ? 32 : 25,
          height: 1.35,
          fontWeight: FontWeight.w800,
          letterSpacing: -.5,
        ),
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Icon(
            Icons.schedule_rounded,
            size: 16,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              article.timeLabel,
              style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),
      AspectRatio(
        aspectRatio: 16 / 9,
        child: ArticleImage(url: article.imageUrl, large: true),
      ),
      const SizedBox(height: 10),
      Text(
        article.imageUrl == null
            ? 'Bản tin này chưa cung cấp hình ảnh.'
            : 'Ảnh từ VnExpress',
        style: TextStyle(color: colors.onSurfaceVariant, fontSize: 11),
      ),
      if (article.summary.isNotEmpty) ...[
        const SizedBox(height: 24),
        SelectableText(
          article.summary,
          key: const ValueKey('detail-summary'),
          style: const TextStyle(
            fontSize: 17,
            height: 1.7,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ];
  }

  List<Widget> _buildFullContent(BuildContext context, ArticleContent content) {
    final widgets = <Widget>[];

    if (content.lead.isNotEmpty &&
        _normalise(content.lead) != _normalise(widget.article.summary)) {
      widgets.add(
        SelectableText(
          content.lead,
          style: const TextStyle(
            fontSize: 17,
            height: 1.75,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
      widgets.add(const SizedBox(height: 18));
    }

    for (final block in content.blocks) {
      if (_duplicatesCoverImage(block)) continue;
      widgets.add(_ArticleBlockView(block: block));
    }

    if (content.author.isNotEmpty) {
      widgets.add(const SizedBox(height: 8));
      widgets.add(
        Align(
          alignment: Alignment.centerRight,
          child: SelectableText(
            content.author,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      );
    }

    widgets.add(const SizedBox(height: 24));
    widgets.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.verified_rounded,
            size: 17,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 7),
          const Flexible(
            child: Text(
              'Nguồn: RSS và bài viết gốc VnExpress',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );

    return widgets;
  }

  bool _duplicatesCoverImage(ArticleBlock block) {
    if (block.type != ArticleBlockType.image ||
        block.imageUrl == null ||
        widget.article.imageUrl == null) {
      return false;
    }
    try {
      final cover = Uri.parse(widget.article.imageUrl.toString());
      return cover.path == block.imageUrl!.path;
    } on FormatException {
      return false;
    }
  }

  String _normalise(String value) =>
      value.replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();
}

class _ArticleBlockView extends StatelessWidget {
  const _ArticleBlockView({required this.block});

  final ArticleBlock block;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    switch (block.type) {
      case ArticleBlockType.heading:
        return Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 10),
          child: SelectableText(
            block.text!,
            style: const TextStyle(
              fontSize: 20,
              height: 1.45,
              fontWeight: FontWeight.w800,
            ),
          ),
        );
      case ArticleBlockType.quote:
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: .08),
            border: Border(left: BorderSide(color: colors.primary, width: 4)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SelectableText(
            block.text!,
            style: const TextStyle(
              fontSize: 17,
              height: 1.75,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      case ArticleBlockType.image:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              block.imageUrl.toString(),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 220,
                color: colors.surfaceContainerHighest,
                alignment: Alignment.center,
                child: const Icon(Icons.broken_image_outlined, size: 42),
              ),
            ),
          ),
        );
      case ArticleBlockType.caption:
        return Padding(
          padding: const EdgeInsets.only(bottom: 13),
          child: SelectableText(
            block.text!,
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              fontStyle: FontStyle.italic,
              color: colors.onSurfaceVariant,
            ),
          ),
        );
      case ArticleBlockType.paragraph:
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SelectableText(
            block.text!,
            style: const TextStyle(fontSize: 17, height: 1.85),
          ),
        );
    }
  }
}

class _LoadingContent extends StatelessWidget {
  const _LoadingContent();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 14),
          Text('Đang tải nội dung bài viết từ VnExpress...'),
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded, color: colors.onErrorContainer),
          const SizedBox(height: 10),
          Text(
            'Chưa tải được toàn bộ nội dung bài báo. '
            'Kiểm tra kết nối mạng rồi thử lại.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.onErrorContainer),
          ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}
