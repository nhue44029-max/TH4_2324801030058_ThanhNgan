import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'models/article.dart';
import 'screens/detail_page.dart';
import 'screens/feed_page.dart';
import 'screens/settings_page.dart';
import 'screens/topics_page.dart';
import 'services/rss_service.dart';
import 'services/theme_controller.dart';
import 'theme/app_theme.dart';
import 'widgets/article_card.dart';

class SacTinApp extends StatelessWidget {
  const SacTinApp({super.key, required this.themeController, this.service});
  final ThemeController themeController;
  final RssService? service;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: themeController,
    builder: (context, _) => MaterialApp(
      title: 'Sắc Tin – Đọc báo online',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: themeController.mode,
      locale: const Locale('vi'),
      supportedLocales: const [Locale('vi')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: _NewsShell(themeController: themeController, service: service),
    ),
  );
}

class _NewsShell extends StatefulWidget {
  const _NewsShell({required this.themeController, this.service});
  final ThemeController themeController;
  final RssService? service;
  @override
  State<_NewsShell> createState() => _NewsShellState();
}

class _NewsShellState extends State<_NewsShell> {
  late final RssService _service = widget.service ?? RssService();
  int _tab = 0;
  final _visited = <int>{0};
  Article? _article;
  final _featuredKey = GlobalKey<FeedPageState>();
  final _latestKey = GlobalKey<FeedPageState>();
  final _topicsKey = GlobalKey<TopicsPageState>();

  @override
  void dispose() {
    if (widget.service == null) _service.dispose();
    super.dispose();
  }

  void _openArticle(Article article) => setState(() => _article = article);
  void _goBack() => setState(() => _article = null);
  void _refresh() {
    switch (_tab) {
      case 0:
        _featuredKey.currentState?.refresh();
      case 1:
        _topicsKey.currentState?.refresh();
      case 2:
        _latestKey.currentState?.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final detail = _article != null;
    final wide = MediaQuery.sizeOf(context).width >= 700;
    final title = detail
        ? 'Chi tiết tin'
        : ['ĐỌC BÁO ONLINE', 'CHỦ ĐỀ', 'TIN MỚI NHẤT', 'CÀI ĐẶT'][_tab];
    return PopScope(
      canPop: !detail,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && detail) _goBack();
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: wide ? 86 : 74,
          automaticallyImplyLeading: false,
          titleSpacing: wide ? 28 : 18,
          title: Row(
            children: [
              if (detail) ...[
                IconButton(
                  key: const ValueKey('back-to-list'),
                  onPressed: _goBack,
                  tooltip: 'Quay lại danh sách',
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: 8),
              ] else ...[
                const BrandMark(size: 38),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: wide ? 20 : 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Sắc Tin · Muôn sắc cuộc sống',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w400,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            if (!detail && _tab != 3)
              Padding(
                padding: EdgeInsets.only(right: wide ? 28 : 12),
                child: IconButton.filledTonal(
                  key: const ValueKey('refresh-feed'),
                  onPressed: _refresh,
                  tooltip: 'Tải lại tin',
                  icon: const Icon(Icons.refresh_rounded, size: 23),
                ),
              ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(height: 1, color: colors.outlineVariant),
          ),
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 940),
              child: IndexedStack(
                index: detail ? 1 : 0,
                sizing: StackFit.expand,
                children: [
                  IndexedStack(
                    index: _tab,
                    sizing: StackFit.expand,
                    children: [
                      FeedPage(
                        key: _featuredKey,
                        service: _service,
                        feedUrl: RssService.featuredUrl,
                        onArticle: _openArticle,
                        title: 'Tin nổi bật',
                      ),
                      if (_visited.contains(1))
                        TopicsPage(
                          key: _topicsKey,
                          service: _service,
                          onArticle: _openArticle,
                        )
                      else
                        const SizedBox.shrink(),
                      if (_visited.contains(2))
                        FeedPage(
                          key: _latestKey,
                          service: _service,
                          feedUrl: RssService.latestUrl,
                          onArticle: _openArticle,
                          title: 'Tin mới nhất',
                          limit: 10,
                        )
                      else
                        const SizedBox.shrink(),
                      SettingsPage(controller: widget.themeController),
                    ],
                  ),
                  if (detail)
                    DetailPage(key: ValueKey(_article!.url), article: _article!)
                  else
                    const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(top: BorderSide(color: colors.outlineVariant)),
          ),
          child: SafeArea(
            top: false,
            child: Center(
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: NavigationBar(
                  height: 76,
                  backgroundColor: colors.surface,
                  elevation: 0,
                  indicatorColor: colors.primary.withValues(alpha: .12),
                  labelTextStyle: WidgetStateProperty.resolveWith(
                    (states) => TextStyle(
                      fontSize: 11,
                      fontWeight: states.contains(WidgetState.selected)
                          ? FontWeight.w800
                          : FontWeight.w500,
                      color: states.contains(WidgetState.selected)
                          ? colors.primary
                          : colors.onSurfaceVariant,
                    ),
                  ),
                  selectedIndex: _tab,
                  onDestinationSelected: (index) => setState(() {
                    _tab = index;
                    _visited.add(index);
                    _article = null;
                  }),
                  destinations: const [
                    NavigationDestination(
                      key: ValueKey('nav-featured'),
                      icon: Icon(Icons.newspaper_outlined),
                      selectedIcon: Icon(Icons.newspaper_rounded),
                      label: 'Tin tổng hợp',
                    ),
                    NavigationDestination(
                      key: ValueKey('nav-topics'),
                      icon: Icon(Icons.grid_view_outlined),
                      selectedIcon: Icon(Icons.grid_view_rounded),
                      label: 'Chủ đề',
                    ),
                    NavigationDestination(
                      key: ValueKey('nav-latest'),
                      icon: Icon(Icons.bolt_outlined),
                      selectedIcon: Icon(Icons.bolt_rounded),
                      label: 'Tin mới nhất',
                    ),
                    NavigationDestination(
                      key: ValueKey('nav-settings'),
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings_rounded),
                      label: 'Cài đặt',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
