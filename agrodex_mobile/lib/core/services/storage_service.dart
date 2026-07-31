import 'package:agrodex_mobile/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Secure local storage wrapper for preferences such as theme mode and locale.
class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Theme Mode Storage ('system', 'light', 'dark')
  String? getThemeMode() {
    return _prefs.getString(AppConstants.themeStorageKey);
  }

  Future<void> saveThemeMode(String themeMode) async {
    await _prefs.setString(AppConstants.themeStorageKey, themeMode);
  }

  // Locale Code Storage (e.g., 'en', 'fr', 'es')
  String? getLocaleCode() {
    return _prefs.getString(AppConstants.localeStorageKey);
  }

  Future<void> saveLocaleCode(String localeCode) async {
    await _prefs.setString(AppConstants.localeStorageKey, localeCode);
  }

  /// Direct access to underlying [SharedPreferences] instance.
  SharedPreferences get prefs => _prefs;

  /// Get arbitrary string by key.
  String? getString(String key) {
    return _prefs.getString(key);
  }

  /// Save arbitrary string by key.
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  Future<void> clear() async {
    await _prefs.clear();
  }
}
