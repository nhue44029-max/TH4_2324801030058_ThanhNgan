import 'package:flutter/material.dart';

class NewsTopic {
  const NewsTopic(
    this.name,
    this.slug,
    this.icon,
    this.color,
    this.description,
  );
  final String name;
  final String slug;
  final IconData icon;
  final Color color;
  final String description;
  String get feedUrl => 'https://vnexpress.net/rss/$slug.rss';

  static const all = [
    NewsTopic(
      'Thời sự',
      'thoi-su',
      Icons.public_rounded,
      Color(0xFFCF3D50),
      'Nhịp sống Việt Nam',
    ),
    NewsTopic(
      'Thế giới',
      'the-gioi',
      Icons.language_rounded,
      Color(0xFF6844D4),
      'Chuyển động toàn cầu',
    ),
    NewsTopic(
      'Kinh doanh',
      'kinh-doanh',
      Icons.business_center_rounded,
      Color(0xFF007C8C),
      'Thị trường & kinh tế',
    ),
    NewsTopic(
      'Thể thao',
      'the-thao',
      Icons.sports_soccer_rounded,
      Color(0xFF317245),
      'Sống cùng đam mê',
    ),
    NewsTopic(
      'Giải trí',
      'giai-tri',
      Icons.movie_filter_rounded,
      Color(0xFFAA397F),
      'Văn hóa & nghệ thuật',
    ),
    NewsTopic(
      'Giáo dục',
      'giao-duc',
      Icons.school_rounded,
      Color(0xFF3868BE),
      'Tri thức mỗi ngày',
    ),
    NewsTopic(
      'Sức khỏe',
      'suc-khoe',
      Icons.favorite_rounded,
      Color(0xFFCC4A3B),
      'Chăm sóc bản thân',
    ),
    NewsTopic(
      'Du lịch',
      'du-lich',
      Icons.flight_takeoff_rounded,
      Color(0xFF007F78),
      'Khám phá những miền đất',
    ),
    NewsTopic(
      'Đời sống',
      'gia-dinh',
      Icons.local_florist_rounded,
      Color(0xFF987016),
      'Những điều gần gũi',
    ),
    NewsTopic(
      'Pháp luật',
      'phap-luat',
      Icons.balance_rounded,
      Color(0xFF6151A8),
      'Thông tin pháp luật',
    ),
    NewsTopic(
      'Xe',
      'oto-xe-may',
      Icons.directions_car_rounded,
      Color(0xFF466478),
      'Sau những tay lái',
    ),
    NewsTopic(
      'Góc nhìn',
      'goc-nhin',
      Icons.lightbulb_rounded,
      Color(0xFF99621C),
      'Thêm một góc nhìn',
    ),
  ];
}
