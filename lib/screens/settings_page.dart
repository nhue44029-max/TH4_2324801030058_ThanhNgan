import 'package:flutter/material.dart';

import '../services/theme_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/article_card.dart';

const studentInfo =
    'Lớp: D23KTPM01\n'
    'MSSV: 2324801030058\n'
    'Họ tên: Nguyễn Thanh Ngân';


class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.controller});
  final ThemeController controller;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(22),
      children: [
        const SizedBox(height: 8),
        const Text(
          'Một chút riêng của bạn',
          style: TextStyle(
            fontSize: 27,
            letterSpacing: -.6,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Chọn giao diện phù hợp với cách bạn đọc.',
          style: TextStyle(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 28),
        const _SectionLabel('GIAO DIỆN'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: SwitchListTile(
              key: const ValueKey('theme-switch'),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              secondary: Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  controller.isDark
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  color: colors.primary,
                ),
              ),
              title: const Text(
                'Chế độ tối',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  controller.isDark
                      ? 'Dịu mắt với tông màu trầm'
                      : 'Tươi sáng cho ngày mới',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              value: controller.isDark,
              onChanged: controller.saving ? null : controller.setDark,
            ),
          ),
        ),
        if (controller.storageError != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              controller.storageError!,
              style: TextStyle(color: colors.error),
            ),
          ),
        const SizedBox(height: 10),
        Text(
          'Lựa chọn được lưu cho lần mở ứng dụng tiếp theo.',
          style: TextStyle(
            fontSize: 12,
            height: 1.5,
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 30),
        const _SectionLabel('VỀ ỨNG DỤNG'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const BrandMark(size: 54),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sắc Tin',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -.6,
                            ),
                          ),
                          Text(
                            'Đọc báo online · Phiên bản 1.0.0',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Muôn sắc tin tức. Một nơi để đọc.',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 8),
                Text(
                  'Khám phá tin tổng hợp, các chủ đề yêu thích và những cập nhật mới nhất từ VnExpress.',
                  style: TextStyle(color: colors.onSurfaceVariant, height: 1.7),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.school_outlined,
                      color: colors.primary,
                      size: 21,
                    ),
                    const SizedBox(width: 9),
                    const Expanded(
                      child: Text(
                        'Thông tin sinh viên',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const SelectableText(
                  studentInfo,
                  key: ValueKey('student-info'),
                  style: TextStyle(height: 1.85, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final color in [
              AppColors.coral,
              AppColors.purple,
              AppColors.teal,
              AppColors.amber,
            ])
              Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
          ],
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12, left: 2),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 11,
        letterSpacing: 1.4,
        fontWeight: FontWeight.w800,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
  );
}
