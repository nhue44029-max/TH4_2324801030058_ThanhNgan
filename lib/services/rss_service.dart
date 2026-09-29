import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import '../models/article.dart';

class FeedException implements Exception {
  const FeedException(this.message);
  final String message;
  @override
  String toString() => message;
}

class RssService {
  RssService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;
  static const featuredUrl = 'https://vnexpress.net/rss/tin-noi-bat.rss';
  static const latestUrl = 'https://vnexpress.net/rss/tin-moi-nhat.rss';

  Future<List<Article>> fetch(String feedUrl, {int? limit}) async {
    try {
      final response = await _client
          .get(
            Uri.parse(feedUrl),
            headers: {
              'Accept': 'application/rss+xml, application/xml, text/xml',
            },
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        throw FeedException(
          'VnExpress chưa phản hồi thành công '
          '(HTTP ${response.statusCode}). Vui lòng thử lại.',
        );
      }
      return parse(utf8.decode(response.bodyBytes), limit: limit);
    } on FeedException {
      rethrow;
    } on TimeoutException {
      throw const FeedException(
        'Kết nối mất quá nhiều thời gian. Hãy kiểm tra mạng và thử lại.',
      );
    } on SocketException {
      throw const FeedException(
        'Không thể kết nối. Hãy kiểm tra Wi-Fi hoặc dữ liệu di động và thử lại.',
      );
    } on http.ClientException {
      throw const FeedException(
        'Không thể kết nối đến VnExpress. Hãy kiểm tra kết nối mạng và thử lại.',
      );
    } on FormatException {
      throw const FeedException(
        'Dữ liệu nhận được không hợp lệ. Vui lòng thử lại.',
      );
    } catch (_) {
      throw const FeedException(
        'Chưa thể tải bản tin lúc này. Vui lòng thử lại.',
      );
    }
  }

  /// Invalid items are skipped; order and the first-ten boundary are preserved.
  static List<Article> parse(String source, {int? limit}) {
    final XmlDocument document;
    try {
      document = XmlDocument.parse(source);
    } on XmlException {
      throw const FeedException(
        'Bản tin RSS không hợp lệ. Vui lòng thử lại sau.',
      );
    }
    final channel = document.rootElement.getElement('channel');
    if (document.rootElement.name.local != 'rss' || channel == null) {
      throw const FeedException('Nguồn tin không đúng định dạng RSS.');
    }
    final items = channel.findElements('item');
    final selected = limit == null ? items : items.take(limit);
    final articles = <Article>[];
    final seen = <String>{};
    for (final item in selected) {
      try {
        final title = plainText(item.getElement('title')?.innerText ?? '');
        final url = _webUri(item.getElement('link')?.innerText);
        if (title.isEmpty ||
            url == null ||
            !(url.host == 'vnexpress.net' ||
                url.host.endsWith('.vnexpress.net')) ||
            !seen.add(url.toString())) {
          continue;
        }
        final description = item.getElement('description')?.innerText ?? '';
        final fragment = html.parseFragment(description);
        Uri? image;
        for (final img in fragment.querySelectorAll('img')) {
          image = _webUri(
            img.attributes['src'] ?? img.attributes['data-src'],
            base: url,
          );
          if (image != null) break;
        }
        if (image == null) {
          for (final element in item.childElements) {
            if ((element.name.local == 'content' ||
                    element.name.local == 'thumbnail') ||
                (element.name.local == 'enclosure' &&
                    (element.getAttribute('type') ?? '').startsWith(
                      'image/',
                    ))) {
              image = _webUri(element.getAttribute('url'), base: url);
              if (image != null) break;
            }
          }
        }
        articles.add(
          Article(
            title: title,
            url: url,
            summary: plainText(description),
            imageUrl: image,
            publishedAt: parseDate(item.getElement('pubDate')?.innerText ?? ''),
          ),
        );
      } on FormatException {
        continue;
      } on ArgumentError {
        continue;
      }
    }
    if (items.isNotEmpty && articles.isEmpty) {
      throw const FeedException(
        'Bản tin hiện không có bài viết hợp lệ. Vui lòng thử lại sau.',
      );
    }
    return List.unmodifiable(articles);
  }

  static Uri? _webUri(String? value, {Uri? base}) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = Uri.tryParse(value.trim());
    if (parsed == null) return null;
    final uri = (base ?? Uri.parse('https://vnexpress.net')).resolveUri(parsed);
    if (!['http', 'https'].contains(uri.scheme) ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty) {
      return null;
    }
    return uri.replace(scheme: 'https');
  }

  static String plainText(String value) {
    final fragment = html.parseFragment(value);
    for (final node in fragment.querySelectorAll('script, style, img')) {
      node.remove();
    }
    for (final node in fragment.querySelectorAll('br')) {
      node.replaceWith(html.parseFragment(' '));
    }
    for (final node in fragment.querySelectorAll('p, div, li')) {
      node.nodes.add(dom.Text(' '));
    }
    return (fragment.text ?? '').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static DateTime? parseDate(String value) {
    final input = value.trim();
    if (input.isEmpty) return null;
    final iso = DateTime.tryParse(input);
    if (iso != null) return iso;
    final match = RegExp(
      r'^(?:[A-Za-z]{3},?\s+)?(\d{1,2})\s+([A-Za-z]{3})\s+(\d{4})\s+'
      r'(\d{2}):(\d{2})(?::(\d{2}))?\s+(GMT|UTC|[+-]\d{4})$',
      caseSensitive: false,
    ).firstMatch(input);
    if (match == null) return null;
    const months = [
      'jan',
      'feb',
      'mar',
      'apr',
      'may',
      'jun',
      'jul',
      'aug',
      'sep',
      'oct',
      'nov',
      'dec',
    ];
    final month = months.indexOf(match[2]!.toLowerCase()) + 1;
    if (month == 0) return null;
    final day = int.parse(match[1]!);
    final year = int.parse(match[3]!);
    final hour = int.parse(match[4]!);
    final minute = int.parse(match[5]!);
    final second = int.parse(match[6] ?? '0');
    final date = DateTime.utc(year, month, day, hour, minute, second);
    if (date.day != day ||
        date.month != month ||
        hour > 23 ||
        minute > 59 ||
        second > 59) {
      return null;
    }
    final zone = match[7]!;
    if (zone.startsWith('+') || zone.startsWith('-')) {
      final hours = int.parse(zone.substring(1, 3));
      final minutes = int.parse(zone.substring(3, 5));
      if (hours > 23 || minutes > 59) return null;
      final offset = (hours * 60 + minutes) * (zone.startsWith('-') ? -1 : 1);
      return date.subtract(Duration(minutes: offset));
    }
    return date;
  }

  void dispose() => _client.close();
}
