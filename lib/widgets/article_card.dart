import 'package:flutter/material.dart';

import '../models/article.dart';
import '../theme/app_theme.dart';

class ArticleImage extends StatelessWidget {
  const ArticleImage({super.key, required this.url, this.large = false});
  final Uri? url;
  final bool large;

  Widget _placeholder(BuildContext context, {bool loading = false}) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ColoredBox(
      color: dark ? const Color(0xFF343047) : const Color(0xFFF0EBFF),
      child: Center(
        child: loading
            ? const SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_stories_rounded,
                    size: large ? 48 : 30,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  if (large) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Sắc Tin · Chưa có hình ảnh',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(large ? 22 : 13),
    child: url == null
        ? _placeholder(context)
        : Image.network(
            url.toString(),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            cacheWidth: large ? 1400 : 440,
            excludeFromSemantics: true,
            loadingBuilder: (context, child, progress) =>
                progress == null ? child : _placeholder(context, loading: true),
            errorBuilder: (context, error, stackTrace) => _placeholder(context),
          ),
  );
}

class ArticleCard extends StatelessWidget {
  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
    required this.index,
  });
  final Article article;
  final VoidCallback onTap;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 640;
        final compact = constraints.maxWidth < 360;
        final imageWidth = wide ? 174.0 : (compact ? 88.0 : 110.0);
        return Semantics(
          button: true,
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.all(wide ? 20 : 13),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (wide) ...[
                            Text(
                              'BẢN TIN ${(index + 1).toString().padLeft(2, '0')}',
                              style: TextStyle(
                                color: colors.primary,
                                fontSize: 10,
                                letterSpacing: 1.4,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          Text(
                            article.title,
                            style: TextStyle(
                              fontSize: wide ? 19 : 15,
                              fontWeight: FontWeight.w700,
                              height: 1.45,
                              letterSpacing: -.2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'VnExpress',
                                  style: TextStyle(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(text: ' · ${article.dateLabel}'),
                              ],
                            ),
                            style: TextStyle(
                              fontSize: wide ? 12 : 11,
                              color: colors.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: wide ? 26 : 13),
                    SizedBox(
                      width: imageWidth,
                      height: wide ? 112 : 88,
                      child: ArticleImage(url: article.imageUrl),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 42});
  final double size;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.coral, AppColors.purple],
      ),
      borderRadius: BorderRadius.circular(size * .32),
    ),
    child: Icon(
      Icons.auto_stories_rounded,
      size: size * .55,
      color: Colors.white,
    ),
  );
}
