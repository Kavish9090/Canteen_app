import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  final AuthService _authService = AuthService();

  Future<void> fetchUser(String uid) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.getUserDetails(uid);
    } catch (e) {
      print("Error loading user profile: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setUser(UserModel userModel) {
    _user = userModel;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
