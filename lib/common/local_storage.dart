import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static final _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _fcmTokenKey = 'fcm_token';
  static const _key = "pending_purchase";
  static const _purchaseKey = "for_purchase";

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  static Future<void> saveFCMToken(String token) async {
    await _storage.write(key: _fcmTokenKey, value: token);
  }

  static Future<String?> getFCMToken() async {
    return await _storage.read(key: _fcmTokenKey);
  }

  static Future<void> deleteFCMToken() async {
    await _storage.delete(key: _fcmTokenKey);
  }

  static Future<void> savePurchase(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(data));
  }

  static Future<Map<String, dynamic>?> getPurchase() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    return jsonDecode(raw);
  }

  static Future<void> clearPurchase() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
// Save bool for _purchaseKey

  static Future<void> saveBool(bool value) async {
    await _storage.write(
      key: _purchaseKey, // Use the predefined _purchaseKey

      value: value.toString(), // Convert bool to String (true/false)
    );
  }

  static Future<void> saveCategorySelected(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('category_selected', value);
  }

  static Future<bool> getCategorySelected() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('category_selected') ?? false;
  }
// Get bool for _purchaseKey

  static Future<bool?> getBool() async {
    final value = await _storage.read(key: _purchaseKey); // Use _purchaseKey

    if (value == null) return null;

    return value.toLowerCase() == 'true'; // Convert String back to bool
  }

// Delete bool for _purchaseKey

  static Future<void> deleteBool() async {
    await _storage.delete(key: _purchaseKey); // Use _purchaseKey
  }
}
