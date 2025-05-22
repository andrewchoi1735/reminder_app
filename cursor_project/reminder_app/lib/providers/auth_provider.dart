import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userId;

  bool get isLoggedIn => _isLoggedIn;
  String? get userId => _userId;

  AuthProvider() {
    _loadUser(); // 생성자에서 로그인 상태 복원 시도
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getString('logged_in_user');

    if (savedUserId != null) {
      _userId = savedUserId;
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  Future<bool> login(String userId, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPassword = prefs.getString('password_$userId');

    if (savedPassword == password) {
      _isLoggedIn = true;
      _userId = userId;
      await prefs.setString('logged_in_user', userId); // 로그인 상태 저장
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String userId, String password) async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('password_$userId')) {
      return false; // 이미 존재하는 사용자
    }

    await prefs.setString('password_$userId', password);

    _isLoggedIn = true;
    _userId = userId;
    await prefs.setString('logged_in_user', userId); // 로그인 상태 저장
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = false;
    _userId = null;
    await prefs.remove('logged_in_user'); // 로그인 정보 삭제
    notifyListeners();
  }
  Future<void> init() async {
    await _loadUser();
  }
}
