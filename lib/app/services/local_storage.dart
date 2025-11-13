import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum StorageKey { user, token, theme }

class LocalStorageService extends GetxService {
  SharedPreferences? _sharedPreferences;

  Future<LocalStorageService> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    return this;
  }

  // Generic method to save data
  Future<bool> saveData(StorageKey key, dynamic value) async {
    final keyString = key.toString();
    if (value == null) {
      return _sharedPreferences?.remove(keyString) ?? false;
    }

    if (value is String) {
      return _sharedPreferences?.setString(keyString, value) ?? false;
    } else if (value is int) {
      return _sharedPreferences?.setInt(keyString, value) ?? false;
    } else if (value is bool) {
      return _sharedPreferences?.setBool(keyString, value) ?? false;
    } else if (value is double) {
      return _sharedPreferences?.setDouble(keyString, value) ?? false;
    } else {
      // For complex objects, convert to JSON
      return _sharedPreferences?.setString(keyString, json.encode(value)) ??
          false;
    }
  }

  // Generic method to get data
  T? getData<T>(StorageKey key, {T? defaultValue}) {
    final keyString = key.toString();
    final value = _sharedPreferences?.get(keyString);

    if (value == null) return defaultValue;

    if (T == String && value is String) {
      return value as T;
    } else if (T == int && value is int) {
      return value as T;
    } else if (T == bool && value is bool) {
      return value as T;
    } else if (T == double && value is double) {
      return value as T;
    }

    return defaultValue;
  }

  // Get string data
  String? getString(StorageKey key) {
    return _sharedPreferences?.getString(key.toString());
  }

  // Get JSON and decode
  Map<String, dynamic>? getJson(StorageKey key) {
    final rawJson = _sharedPreferences?.getString(key.toString());
    if (rawJson == null) return null;

    try {
      return jsonDecode(rawJson) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  // Remove data
  Future<bool> removeData(StorageKey key) async {
    return _sharedPreferences?.remove(key.toString()) ?? false;
  }

  // Clear all data
  Future<bool> clearAll() async {
    return _sharedPreferences?.clear() ?? false;
  }

  // Check if key exists
  bool hasData(StorageKey key) {
    return _sharedPreferences?.containsKey(key.toString()) ?? false;
  }
}
