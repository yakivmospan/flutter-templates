import 'package:shared_preferences/shared_preferences.dart';

class SettingsDao {
  final SharedPreferences _preferences;

  static const String _keyDarkMode = 'dark_mode';

  SettingsDao(this._preferences);

  Future<bool> isDarkMode() async {
    return _preferences.getBool(_keyDarkMode) ?? false;
  }

  Future<void> setDarkMode(bool isDark) async {
    await _preferences.setBool(_keyDarkMode, isDark);
  }

  Future<void> clear() async {
    await _preferences.clear();
  }
}