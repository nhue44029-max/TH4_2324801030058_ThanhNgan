import 'dart:convert';

import 'package:bao_online/app.dart';
import 'package:bao_online/screens/settings_page.dart';
import 'package:bao_online/services/rss_service.dart';
import 'package:bao_online/services/theme_controller.dart';
import 'package:bao_online/widgets/article_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'rss_service_test.dart' show item, rss;

class MemoryThemeController extends ThemeController {
  bool dark = false;
  @override
  bool get isDark => dark;
  @override
  ThemeMode get mode => dark ? ThemeMode.dark : ThemeMode.light;
  @override
  Future<void> setDark(bool value) async {
    dark = value;
    notifyListeners();
  }
}

void main() {
  WidgetController.hitTestWarningShouldBeFatal = true;
  testWidgets(
    'Phone and desktop: navigation, matching details, topic, ten latest, theme',
    (tester) async {
      final requested = <String>[];
      final service = RssService(
        client: MockClient((request) async {
          requested.add(request.url.path);
          return http.Response.bytes(
            utf8.encode(
              rss(
                List.generate(
                  14,
                  (i) => item(i, description: 'Tóm tắt kiểm thử $i'),
                ).join(),
              ),
            ),
            200,
          );
        }),
      );
      final theme = MemoryThemeController();
      addTearDown(service.dispose);
      addTearDown(theme.dispose);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        SacTinApp(themeController: theme, service: service),
      );
      await tester.pumpAndSettle();
      expect(find.text('ĐỌC BÁO ONLINE'), findsOneWidget);
      expect(requested.first, '/rss/tin-noi-bat.rss');
      // Tap the image side of the complete article card.
      await tester.tap(
        find.descendant(
          of: find.byKey(const ValueKey('article-0')),
          matching: find.byType(ArticleImage),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Bản tin 0 & thông tin'), findsOneWidget);
      expect(find.text('Tóm tắt kiểm thử 0'), findsOneWidget);
      expect(find.byKey(const ValueKey('nav-topics')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('back-to-list')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('nav-topics')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('topic-the-thao')));
      await tester.pumpAndSettle();
      expect(requested.last, '/rss/the-thao.rss');
      await tester.tap(find.byKey(const ValueKey('nav-latest')));
      await tester.pumpAndSettle();
      expect(requested.last, '/rss/tin-moi-nhat.rss');
      expect(find.text('10 tin'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('nav-settings')));
      await tester.pumpAndSettle();
      expect(find.text(studentInfo), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('theme-switch')));
      await tester.pumpAndSettle();
      expect(theme.isDark, isTrue);
      expect(
        Theme.of(tester.element(find.byType(NavigationBar))).brightness,
        Brightness.dark,
      );
      // Narrow phone, then desktop. No layout exceptions allowed.
      for (final size in [const Size(320, 740), const Size(1120, 820)]) {
        tester.view.physicalSize = size;
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        for (final nav in [
          'nav-topics',
          'nav-featured',
          'nav-latest',
          'nav-settings',
        ]) {
          await tester.tap(find.byKey(ValueKey(nav)));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      }
    },
  );

  testWidgets(
    'Offline error retries, refresh preserves existing articles, empty feed handled',
    (tester) async {
      var status = 503;
      var content = rss(item(1));
      final service = RssService(
        client: MockClient(
          (_) async => http.Response.bytes(utf8.encode(content), status),
        ),
      );
      addTearDown(service.dispose);
      final theme = MemoryThemeController();
      addTearDown(theme.dispose);
      await tester.pumpWidget(
        SacTinApp(themeController: theme, service: service),
      );
      await tester.pumpAndSettle();
      expect(find.text('Thử lại'), findsOneWidget);
      status = 200;
      await tester.ensureVisible(find.text('Thử lại'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();
      expect(find.text('Bản tin 1 & thông tin'), findsOneWidget);
      status = 503;
      await tester.tap(find.byKey(const ValueKey('refresh-feed')));
      await tester.pumpAndSettle();
      expect(find.text('Chưa thể làm mới'), findsOneWidget);
      expect(find.text('Bản tin 1 & thông tin'), findsOneWidget);
      status = 200;
      content = rss('');
      await tester.tap(find.byKey(const ValueKey('refresh-feed')));
      await tester.pumpAndSettle();
      expect(find.text('Bản tin đang chờ cập nhật'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
