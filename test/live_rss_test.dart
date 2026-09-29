import 'package:bao_online/models/news_topic.dart';
import 'package:bao_online/services/rss_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Live VnExpress: featured, latest and all configured topics',
    () async {
      final service = RssService();
      addTearDown(service.dispose);
      for (final url in [
        RssService.featuredUrl,
        RssService.latestUrl,
        ...NewsTopic.all.map((topic) => topic.feedUrl),
      ]) {
        final articles = await service.fetch(
          url,
          limit: url == RssService.latestUrl ? 10 : null,
        );
        expect(articles, isNotEmpty, reason: url);
        if (url == RssService.latestUrl) {
          expect(articles.length, lessThanOrEqualTo(10));
        }
        // Captured by the test runner as evidence, never bundled into the app.
        // ignore: avoid_print
        print(
          'LIVE OK $url: ${articles.length} articles, first=${articles.first.url}',
        );
      }
    },
    skip: !const bool.fromEnvironment('LIVE_RSS'),
    timeout: const Timeout(Duration(minutes: 6)),
  );
}
