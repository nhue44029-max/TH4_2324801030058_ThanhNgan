import 'dart:io';
import 'dart:ui' as ui;

import 'package:bao_online/app.dart';
import 'package:bao_online/screens/detail_page.dart';
import 'package:bao_online/screens/settings_page.dart';
import 'package:bao_online/services/theme_controller.dart';
import 'package:bao_online/widgets/article_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final captureKey = GlobalKey();

  Future<void> waitFor(WidgetTester tester, Finder finder) async {
    final deadline = DateTime.now().add(const Duration(seconds: 45));
    while (finder.evaluate().isEmpty && DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 250));
    }
    expect(finder, findsWidgets);
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> capture(String name) async {
    final boundary =
        captureKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final folder = Directory('.verification');
    await folder.create(recursive: true);
    await File('${folder.path}/$name.png')
        .writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
  }

  testWidgets(
    'Windows: real RSS, all screens, original link and persistent theme',
    (tester) async {
      final theme = ThemeController();
      await theme.load();
      final initialMode = theme.isDark;
      await theme.setDark(false);
      await tester.pumpWidget(
        RepaintBoundary(
          key: captureKey,
          child: SacTinApp(themeController: theme),
        ),
      );
      await waitFor(tester, find.byType(ArticleCard));
      await tester.pumpAndSettle(
        const Duration(milliseconds: 200),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 45),
      );
      await capture('windows-light');
      final first = tester
          .widget<ArticleCard>(find.byType(ArticleCard).first)
          .article;
      expect(first.imageUrl, isNotNull);
      expect(first.summary, isNotEmpty);
      await tester.tap(find.byType(ArticleCard).first);
      await tester.pumpAndSettle();
      expect(
        tester.widget<DetailPage>(find.byType(DetailPage)).article.url,
        first.url,
      );
      expect(find.byKey(const ValueKey('nav-featured')), findsOneWidget);
      await capture('windows-detail');
      // Exercise the real Windows url_launcher plugin and exact selected URL.
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('open-original')),
        280,
        scrollable: find
            .descendant(
              of: find.byType(DetailPage),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('open-original')));
      await tester.pumpAndSettle();
      expect(
        find.text('Chưa mở được trình duyệt. Bạn có thể sao chép liên kết.'),
        findsNothing,
      );
      await tester.tap(find.byKey(const ValueKey('back-to-list')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('nav-topics')));
      await tester.pumpAndSettle();
      await capture('windows-topics');
      await tester.tap(find.byKey(const ValueKey('topic-the-thao')));
      await waitFor(tester, find.byType(ArticleCard));
      expect(find.text('Thể thao'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('nav-latest')));
      await waitFor(tester, find.text('10 tin'));
      await tester.pumpAndSettle(
        const Duration(milliseconds: 200),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 45),
      );
      await capture('windows-latest');
      await tester.tap(find.byKey(const ValueKey('refresh-feed')));
      await waitFor(tester, find.text('10 tin'));

      await tester.tap(find.byKey(const ValueKey('nav-settings')));
      await tester.pumpAndSettle();
      expect(find.text(studentInfo), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('theme-switch')));
      await tester.pumpAndSettle();
      expect(theme.isDark, isTrue);
      expect(theme.storageError, isNull);
      final reloaded = ThemeController();
      await reloaded.load();
      expect(reloaded.isDark, isTrue);
      expect(reloaded.storageError, isNull);
      await capture('windows-settings-dark');

      await tester.tap(find.byKey(const ValueKey('nav-featured')));
      await tester.pumpAndSettle();
      await capture('windows-dark');
      await binding.setSurfaceSize(const Size(390, 844));
      await tester.pumpAndSettle();
      await capture('phone-dark');
      await theme.setDark(false);
      await tester.pumpAndSettle();
      await capture('phone-light');
      await tester.tap(find.byKey(const ValueKey('nav-topics')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('all-topics')));
      await tester.pumpAndSettle();
      await capture('phone-topics');
      expect(tester.takeException(), isNull);
      await theme.setDark(initialMode);
      await binding.setSurfaceSize(null);
      await tester.pumpWidget(const SizedBox.shrink());
      theme.dispose();
      reloaded.dispose();
    },
  );
}
