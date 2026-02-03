import '../storage/storage.dart';

abstract class SettingsRepository {
  Future<bool> isDarkMode();
  Future<void> setDarkMode(bool isDark);
}

class SettingsRepositoryImpl implements SettingsRepository {
  final Storage storage;

  SettingsRepositoryImpl({required this.storage});

  @override
  Future<bool> isDarkMode() async {
    return await storage.settingsDao.isDarkMode();
  }

  @override
  Future<void> setDarkMode(bool isDark) async {
    await storage.settingsDao.setDarkMode(isDark);
  }
}