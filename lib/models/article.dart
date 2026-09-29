class Article {
  const Article({
    required this.title,
    required this.url,
    required this.summary,
    this.imageUrl,
    this.publishedAt,
  });

  final String title;
  final Uri url;
  final String summary;
  final Uri? imageUrl;
  final DateTime? publishedAt;

  String get dateLabel {
    final date = publishedAt?.toLocal();
    if (date == null) return 'Chưa có ngày đăng';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String get timeLabel {
    final date = publishedAt?.toLocal();
    if (date == null) return dateLabel;
    return '$dateLabel · ${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
