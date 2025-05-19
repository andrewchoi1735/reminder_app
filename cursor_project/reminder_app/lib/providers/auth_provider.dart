import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userId;

  bool get isLoggedIn => _isLoggedIn;
  String? get userId => _userId;

  Future<bool> login(String userId, String password) async {
    // TODO: 실제 로그인 로직 구현
    final prefs = await SharedPreferences.getInstance();
    final savedPassword = prefs.getString('password_$userId');
    
    if (savedPassword == password) {
      _isLoggedIn = true;
      _userId = userId;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String userId, String password, String birthDate) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (prefs.containsKey('password_$userId')) {
      return false; // 이미 존재하는 사용자
    }

    await prefs.setString('password_$userId', password);
    await prefs.setString('birthdate_$userId', birthDate);
    
    _isLoggedIn = true;
    _userId = userId;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _userId = null;
    notifyListeners();
  }
} 