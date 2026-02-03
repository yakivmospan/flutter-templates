abstract class SettingsRepository {
  Future<bool> isDarkMode();

  Future<void> setDarkMode(bool isDark);
}

class SettingsRepositoryImpl implements SettingsRepository {
  bool _isDarkMode = false;

  @override
  Future<bool> isDarkMode() async {
    return _isDarkMode;
  }

  @override
  Future<void> setDarkMode(bool isDark) async {
    _isDarkMode = isDark;
  }
}