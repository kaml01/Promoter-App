import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefClass {

  static Future<SharedPreferences> get _instance async => _prefs_instance ??= await SharedPreferences.getInstance();
  static SharedPreferences? _prefs_instance;

  static Future<SharedPreferences?> init() async {
    _prefs_instance = await _instance;
    return _prefs_instance;
  }

  Future<bool> getBool(String key) async {
    final p = await _instance;
    return p.getBool(key) ?? false;
  }

  Future setBool(String key, bool value) async {
    final p = await _instance;
    return p.setBool(key, value);
  }

  static int getInt(String key) {
    return _prefs_instance?.getInt(key) ?? 0;
  }

  static Future<bool> setInt(String key, int value) async {
    final p = await _instance;
    return p.setInt(key, value)?? Future.value(false);
  }

  static String getString(String key) {
    return _prefs_instance?.getString(key) ?? '';
  }

  static Future<bool> setString(String key, String value) async {
    final p = await _instance;
    p.setString(key, value);
    return true;
  }

  static Future<bool> setDouble(String key, double value) async {
    print("keyout $value");
    final p = await _instance;
    return p.setDouble(key, value)?? Future.value(false);
  }

  static double getDouble(String key) {
    return _prefs_instance?.getDouble(key) ?? 0.0;
  }

}