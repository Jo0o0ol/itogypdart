import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'roles.dart';

class Session extends ChangeNotifier {
  static const _tokenKey = 'beanhouse_token';
  static const _userKey = 'beanhouse_user';

  String? token;
  String? userId;
  String? email;
  String? fullName;
  AppRole role = AppRole.customer;

  bool get isLoggedIn => token != null && userId != null;

  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString(_tokenKey);
    final raw = prefs.getString(_userKey);

    if (raw != null) {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      userId = '${json['id'] ?? ''}';
      email = '${json['email'] ?? ''}';
      fullName = '${json['full_name'] ?? ''}';
      role = AppRoleX.fromApi('${json['role'] ?? 'customer'}');
    }

    notifyListeners();
  }

  Future<void> setAuth(
    String tokenValue,
    Map<String, dynamic> user,
  ) async {
    token = tokenValue;
    userId = '${user['id'] ?? ''}';
    email = '${user['email'] ?? ''}';
    fullName = '${user['full_name'] ?? user['name'] ?? ''}';
    role = AppRoleX.fromApi('${user['role'] ?? 'customer'}');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, tokenValue);
    await prefs.setString(_userKey, jsonEncode(user));
    notifyListeners();
  }

  Future<void> clear() async {
    token = null;
    userId = null;
    email = null;
    fullName = null;
    role = AppRole.customer;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    notifyListeners();
  }
}
