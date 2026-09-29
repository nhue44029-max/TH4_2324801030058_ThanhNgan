import 'dart:convert';
import 'dart:io';

import 'package:bao_online/services/rss_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

// These inputs exercise broken RSS. The application never uses test data.
String rss(String items) =>
    '<rss version="2.0"><channel>$items</channel></rss>';
String item(
  int id, {
  String description = '',
  String date = '',
  String? link,
}) =>
    '''
<item><title>Bản tin $id &amp; thông tin</title>
<link>${link ?? 'https://vnexpress.net/article-$id.html'}</link>
<description><![CDATA[$description]]></description><pubDate>$date</pubDate></item>''';

void main() {
  test('Parses real VnExpress capture, image, summary, URL and timezone', () {
    final source = File('test/fixtures/vnexpress_featured.xml')
        .readAsStringSync();
    final articles = RssService.parse(source);
    expect(articles, isNotEmpty);
    expect(articles.first.title, contains('Ưu tiên gỡ vướng pháp luật'));
    expect(articles.first.url.path, endsWith('-5125761.html'));
    expect(articles.first.imageUrl?.host, 'i1-vnexpress.vnecdn.net');
    expect(articles.first.summary, contains('Tô Lâm'));
    expect(articles.first.summary, isNot(contains('<img')));
    expect(articles.first.publishedAt, DateTime.utc(2026, 9, 28, 8, 25, 26));
  });

  test(
    'HTML entities, block boundaries, script removal, missing image/date',
    () {
      final article = RssService.parse(
        rss(
          item(
            1,
            description:
                '<p>Một &amp; hai</p><p>Ba<br>Bốn</p><script>bad()</script>',
          ),
        ),
      ).single;
      expect(article.title, 'Bản tin 1 & thông tin');
      expect(article.summary, 'Một & hai Ba Bốn');
      expect(article.imageUrl, isNull);
      expect(article.publishedAt, isNull);
    },
  );

  test('First ten boundary and original feed order are preserved', () {
    final result = RssService.parse(
      rss(List.generate(14, (i) => item(i)).join()),
      limit: 10,
    );
    expect(result.length, 10);
    expect(result.first.url.path, '/article-0.html');
    expect(result.last.url.path, '/article-9.html');
  });

  test('Invalid and duplicate entries skipped; unsafe URLs excluded', () {
    final result = RssService.parse(
      rss(
        '${item(1)}${item(1)}'
        '${item(2, link: 'javascript:alert(1)')}'
        '${item(3, link: 'https://other.example/a')}'
        '<item><title>No link</title></item>'
        '${item(4, date: 'garbage')}',
      ),
    );
    expect(result.length, 2);
    expect(result.last.publishedAt, isNull);
  });

  test('Relative images and enclosure images are supported', () {
    final relative = RssService.parse(
      rss(item(1, description: '<img src="/a.jpg">Text')),
    ).single;
    expect(relative.imageUrl.toString(), 'https://vnexpress.net/a.jpg');
    final enclosed = RssService.parse(
      rss(
        item(2).replaceFirst(
          '</item>',
          '<enclosure type="image/jpeg" url="https://i1-vnexpress.vnecdn.net/x.jpg"/></item>',
        ),
      ),
    ).single;
    expect(enclosed.imageUrl?.path, '/x.jpg');
  });

  test('Empty feed distinct from malformed and unusable RSS', () {
    expect(RssService.parse(rss('')), isEmpty);
    expect(() => RssService.parse('<rss>'), throwsA(isA<FeedException>()));
    expect(() => RssService.parse('<html/>'), throwsA(isA<FeedException>()));
    expect(
      () => RssService.parse(rss('<item/>')),
      throwsA(isA<FeedException>()),
    );
  });

  test(
    'Date parser handles timezone offsets without fabricating invalid dates',
    () {
      expect(
        RssService.parseDate('Tue, 29 Sep 2026 10:00:00 +0700'),
        DateTime.utc(2026, 9, 29, 3),
      );
      expect(
        RssService.parseDate('Tue, 29 Sep 2026 10:00:00 -0500'),
        DateTime.utc(2026, 9, 29, 15),
      );
      expect(
        RssService.parseDate('29 Sep 2026 10:00:00 GMT'),
        DateTime.utc(2026, 9, 29, 10),
      );
      expect(RssService.parseDate('31 Feb 2026 10:00:00 +0700'), isNull);
      expect(RssService.parseDate('bad date'), isNull);
    },
  );

  test(
    'HTTP failure, offline and bad encoding become readable errors',
    () async {
      for (final client in [
        MockClient((_) async => http.Response('Unavailable', 503)),
        MockClient((_) async => throw const SocketException('offline')),
        MockClient((_) async => http.Response.bytes([0xff], 200)),
      ]) {
        final service = RssService(client: client);
        await expectLater(
          service.fetch(RssService.featuredUrl),
          throwsA(isA<FeedException>()),
        );
        service.dispose();
      }
    },
  );

  test('UTF-8 is used even without response charset', () async {
    final service = RssService(
      client: MockClient(
        (_) async => http.Response.bytes(utf8.encode(rss(item(1))), 200),
      ),
    );
    expect(
      (await service.fetch(RssService.featuredUrl)).single.title,
      contains('Bản tin'),
    );
    service.dispose();
  });
}
