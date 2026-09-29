import 'package:flutter/material.dart';

import '../models/article.dart';
import '../models/news_topic.dart';
import '../services/rss_service.dart';
import 'feed_page.dart';

class TopicsPage extends StatefulWidget {
  const TopicsPage({super.key, required this.service, required this.onArticle});
  final RssService service;
  final ValueChanged<Article> onArticle;
  @override
  State<TopicsPage> createState() => TopicsPageState();
}

class TopicsPageState extends State<TopicsPage> {
  NewsTopic? _selected;
  final _feedKey = GlobalKey<FeedPageState>();
  void refresh() => _feedKey.currentState?.refresh();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (_selected != null) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
            child: Row(
              children: [
                TextButton.icon(
                  key: const ValueKey('all-topics'),
                  onPressed: () => setState(() => _selected = null),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Tất cả chủ đề'),
                ),
                const Spacer(),
                Icon(_selected!.icon, color: colors.primary),
              ],
            ),
          ),
          Expanded(
            child: FeedPage(
              key: _feedKey,
              service: widget.service,
              feedUrl: _selected!.feedUrl,
              onArticle: widget.onArticle,
              title: _selected!.name,
              intro: false,
            ),
          ),
        ],
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760
            ? 4
            : (constraints.maxWidth >= 540 ? 3 : 2);
        return CustomScrollView(
          key: const PageStorageKey('topics'),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'THẾ GIỚI MUÔN MÀU',
                      style: TextStyle(
                        color: colors.primary,
                        letterSpacing: 1.3,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Bạn muốn đọc gì?',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Chọn một chủ đề, khám phá những câu chuyện mới.',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
              sliver: SliverGrid.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  mainAxisExtent: MediaQuery.textScalerOf(context).scale(208),
                ),
                itemCount: NewsTopic.all.length,
                itemBuilder: (context, index) {
                  final topic = NewsTopic.all[index];
                  final dark = Theme.of(context).brightness == Brightness.dark;
                  final ink = dark
                      ? Color.lerp(topic.color, Colors.white, .62)!
                      : topic.color;
                  return Material(
                    color: Color.alphaBlend(
                      topic.color.withValues(alpha: dark ? .18 : .085),
                      colors.surface,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      key: ValueKey('topic-${topic.slug}'),
                      onTap: () => setState(() => _selected = topic),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: topic.color.withValues(
                                      alpha: dark ? .24 : .1,
                                    ),
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  child: Icon(topic.icon, color: ink, size: 25),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.north_east_rounded,
                                  color: ink,
                                  size: 17,
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              topic.name,
                              style: TextStyle(
                                color: ink,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              topic.description,
                              style: TextStyle(
                                fontSize: 11,
                                height: 1.4,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
