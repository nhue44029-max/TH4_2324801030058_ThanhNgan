import 'dart:convert';

import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

enum ArticleBlockType { paragraph, heading, quote, image, caption }

class ArticleBlock {
  const ArticleBlock._({required this.type, this.text, this.imageUrl});

  const ArticleBlock.paragraph(String value)
    : this._(type: ArticleBlockType.paragraph, text: value);

  const ArticleBlock.heading(String value)
    : this._(type: ArticleBlockType.heading, text: value);

  const ArticleBlock.quote(String value)
    : this._(type: ArticleBlockType.quote, text: value);

  const ArticleBlock.image(Uri value)
    : this._(type: ArticleBlockType.image, imageUrl: value);

  const ArticleBlock.caption(String value)
    : this._(type: ArticleBlockType.caption, text: value);

  final ArticleBlockType type;
  final String? text;
  final Uri? imageUrl;
}

class ArticleContent {
  const ArticleContent({
    required this.lead,
    required this.author,
    required this.blocks,
  });

  final String lead;
  final String author;
  final List<ArticleBlock> blocks;
}

class ArticleContentException implements Exception {
  const ArticleContentException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ArticleContentService {
  ArticleContentService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  void close() => _client.close();

  static const _blockedClasses = <String>{
    'banner-ads',
    'box-tinlienquanv2',
    'box_brief_info',
    'box_embed_video',
    'box-item-link',
    'related-news',
    'social',
  };

  Future<ArticleContent> load(Uri articleUrl) async {
    if (!_isVnExpressUrl(articleUrl)) {
      throw const ArticleContentException(
        'Liên kết bài viết không thuộc VnExpress.',
      );
    }

    final response = await _client
        .get(
          articleUrl,
          headers: const {
            'Accept': 'text/html,application/xhtml+xml',
            'Accept-Language': 'vi-VN,vi;q=0.9',
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
                'AppleWebKit/537.36 Chrome/125 Safari/537.36',
          },
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw ArticleContentException(
        'VnExpress trả về mã lỗi ${response.statusCode}.',
      );
    }

    final source = utf8.decode(response.bodyBytes, allowMalformed: true);
    final document = html_parser.parse(source);

    final lead = _cleanText(
      document.querySelector('p.description')?.text ?? '',
    );
    final author = _findAuthor(document);
    final root =
        document.querySelector('article.fck_detail') ??
        document.querySelector('.fck_detail');

    var blocks = root == null
        ? const <ArticleBlock>[]
        : _readBlocks(root, articleUrl);

    if (blocks.isEmpty) {
      blocks = _readJsonLd(document);
    }

    if (blocks.isEmpty) {
      throw const ArticleContentException(
        'Chưa đọc được phần nội dung chính của bài báo này.',
      );
    }

    return ArticleContent(lead: lead, author: author, blocks: blocks);
  }

  bool _isVnExpressUrl(Uri uri) {
    final host = uri.host.toLowerCase();
    return uri.scheme == 'https' &&
        (host == 'vnexpress.net' || host.endsWith('.vnexpress.net'));
  }

  List<ArticleBlock> _readBlocks(Element root, Uri baseUrl) {
    final blocks = <ArticleBlock>[];
    String? previousText;

    for (final element in root.querySelectorAll(
      'p, h2, h3, blockquote, figure, img',
    )) {
      if (_isBlocked(element, root)) continue;

      final tag = element.localName;
      if (tag != 'figure' && _hasAncestor(element, 'figure', root)) {
        continue;
      }
      if (tag != 'blockquote' && _hasAncestor(element, 'blockquote', root)) {
        continue;
      }

      if (tag == 'figure') {
        final image = element.querySelector('img');
        final imageUrl = image == null ? null : _readImageUrl(image, baseUrl);
        if (imageUrl != null) {
          blocks.add(ArticleBlock.image(imageUrl));
        }

        final caption = _cleanText(
          element.querySelector('figcaption')?.text ??
              element.querySelector('p.Image')?.text ??
              '',
        );
        if (caption.isNotEmpty) {
          blocks.add(ArticleBlock.caption(caption));
        }
        continue;
      }

      if (tag == 'img') {
        final imageUrl = _readImageUrl(element, baseUrl);
        if (imageUrl != null) {
          blocks.add(ArticleBlock.image(imageUrl));
        }
        continue;
      }

      final text = _cleanText(element.text);
      if (!_shouldKeepText(element, text) || text == previousText) continue;
      previousText = text;

      if (tag == 'h2' || tag == 'h3') {
        blocks.add(ArticleBlock.heading(text));
      } else if (tag == 'blockquote') {
        blocks.add(ArticleBlock.quote(text));
      } else {
        blocks.add(ArticleBlock.paragraph(text));
      }
    }

    return blocks;
  }

  bool _hasAncestor(Element element, String tagName, Element root) {
    Element? current = element.parent;
    while (current != null) {
      if (current.localName == tagName) return true;
      if (current == root) break;
      current = current.parent;
    }
    return false;
  }

  bool _isBlocked(Element element, Element root) {
    for (
      Element? current = element;
      current != null && current != root.parent;
      current = current.parent
    ) {
      if (current.localName == 'script' ||
          current.localName == 'style' ||
          current.localName == 'iframe') {
        return true;
      }
      if (current.classes.any(_blockedClasses.contains)) return true;
    }
    return false;
  }

  bool _shouldKeepText(Element element, String text) {
    if (text.isEmpty) return false;

    final classes = element.classes.map((e) => e.toLowerCase()).toSet();
    if (classes.contains('image') ||
        classes.contains('author_mail') ||
        classes.contains('fig-picture')) {
      return false;
    }

    if ((element.attributes['style'] ?? '').toLowerCase().contains(
      'text-align:right',
    )) {
      return false;
    }

    final lower = text.toLowerCase();
    return !lower.startsWith('xem thêm:') &&
        !lower.startsWith('đọc thêm:') &&
        !lower.startsWith('>>');
  }

  Uri? _readImageUrl(Element image, Uri baseUrl) {
    String? value;
    for (final name in const ['data-src', 'data-original', 'data-url', 'src']) {
      final candidate = image.attributes[name]?.trim();
      if (candidate != null &&
          candidate.isNotEmpty &&
          !candidate.startsWith('data:')) {
        value = candidate;
        break;
      }
    }

    value ??= image.attributes['srcset']
        ?.split(',')
        .first
        .trim()
        .split(RegExp(r'\s+'))
        .first;

    if (value == null || value.isEmpty) return null;
    if (value.startsWith('//')) value = 'https:$value';

    try {
      return baseUrl.resolve(value);
    } on FormatException {
      return null;
    }
  }

  List<ArticleBlock> _readJsonLd(Document document) {
    for (final script in document.querySelectorAll(
      'script[type="application/ld+json"]',
    )) {
      final raw = script.text.trim();
      if (raw.isEmpty) continue;
      try {
        final decoded = jsonDecode(raw);
        final body = _findArticleBody(decoded);
        if (body == null || body.trim().isEmpty) continue;

        return body
            .split(RegExp(r'\n+'))
            .map(_cleanText)
            .where((text) => text.isNotEmpty)
            .map(ArticleBlock.paragraph)
            .toList();
      } on FormatException {
        continue;
      }
    }
    return const [];
  }

  String? _findArticleBody(Object? node) {
    if (node is Map<String, dynamic>) {
      final body = node['articleBody'];
      if (body is String && body.trim().isNotEmpty) return body;
      for (final value in node.values) {
        final found = _findArticleBody(value);
        if (found != null) return found;
      }
    } else if (node is List) {
      for (final value in node) {
        final found = _findArticleBody(value);
        if (found != null) return found;
      }
    }
    return null;
  }

  String _findAuthor(Document document) {
    final author =
        document.querySelector('.author_mail') ??
        document.querySelector('p[style*="text-align:right"]');
    return _cleanText(author?.text ?? '');
  }

  String _cleanText(String value) =>
      value.replaceAll('\u00a0', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
}
