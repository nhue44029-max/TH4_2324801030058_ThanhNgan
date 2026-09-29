import 'package:flutter/material.dart';

import 'app.dart';
import 'services/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeController = ThemeController();
  await themeController.load();
  runApp(SacTinApp(themeController: themeController));
}
