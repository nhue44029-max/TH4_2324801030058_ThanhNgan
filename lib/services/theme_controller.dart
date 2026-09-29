import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeController({SharedPreferencesAsync? preferences})
    : _providedPreferences = preferences;
  final SharedPreferencesAsync? _providedPreferences;
  late final SharedPreferencesAsync _preferences =
      _providedPreferences ?? SharedPreferencesAsync();
  static const preferenceKey = 'sac_tin_dark_mode';
  bool _isDark = false;
  bool _saving = false;
  String? _storageError;
  bool get isDark => _isDark;
  bool get saving => _saving;
  String? get storageError => _storageError;
  ThemeMode get mode => _isDark ? ThemeMode.dark : ThemeMode.light;

  Future<void> load() async {
    try {
      _isDark = await _preferences.getBool(preferenceKey) ?? false;
    } catch (_) {
      _storageError = 'Chưa đọc được tùy chọn giao diện đã lưu.';
    }
    notifyListeners();
  }

  Future<void> setDark(bool value) async {
    if (_saving) return;
    _isDark = value;
    _saving = true;
    _storageError = null;
    notifyListeners();
    try {
      await _preferences.setBool(preferenceKey, value);
    } catch (_) {
      _storageError = 'Giao diện đã đổi nhưng chưa lưu được. Hãy thử lại.';
    } finally {
      _saving = false;
      notifyListeners();
    }
  }
}
