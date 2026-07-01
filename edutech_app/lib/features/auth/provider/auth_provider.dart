import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../model/auth_model.dart';

class AuthProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isInitializing = true;
  String? error;
  AuthModel? currentUser;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    isInitializing = true;
    final token = await TokenStorage.get();
    if (token != null) {
      await _fetchProfile();
    }
    isInitializing = false;
    notifyListeners();
  }

  Future<void> _fetchProfile() async {
    try {
      final res = await ApiClient.dio.get('/users/profile');
      final data = res.data['data'];
      final token = await TokenStorage.get();
      currentUser = AuthModel(
        accessToken: token ?? '',
        fullName: data['fullName'] ?? '',
        email: data['email'] ?? '',
        role: data['role'] ?? 'STUDENT',
      );
    } catch (_) {
      await TokenStorage.delete();
      currentUser = null;
    }
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final res = await ApiClient.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      debugPrint('Login response: ${res.data}');
      final auth = AuthModel.fromJson(res.data['data']);
      await TokenStorage.save(auth.accessToken);
      currentUser = auth;
      return true;
    } catch (e) {
      debugPrint('Login error: $e');
      if (e is DioException) {
        debugPrint('Login response data: ${e.response?.data}');
        debugPrint('Login status: ${e.response?.statusCode}');
      }
      error = _parseError(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String email, String password, String fullName) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final res = await ApiClient.dio.post(
        '/auth/register',
        data: {'email': email, 'password': password, 'fullName': fullName},
      );
      final auth = AuthModel.fromJson(res.data['data']);
      await TokenStorage.save(auth.accessToken);
      currentUser = auth;
      return true;
    } catch (e) {
      error = _parseError(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await TokenStorage.delete();
    currentUser = null;
    notifyListeners();
  }

  void updateCurrentUser({String? fullName}) {
    if (currentUser == null) return;
    currentUser = AuthModel(
      accessToken: currentUser!.accessToken,
      fullName: fullName ?? currentUser!.fullName,
      email: currentUser!.email,
      role: currentUser!.role,
    );
    notifyListeners();
  }

  Future<bool> isLoggedIn() async {
    final token = await TokenStorage.get();
    return token != null;
  }

  String _parseError(dynamic e) {
    try {
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map) {
          return data['message']?.toString() ?? 'Đã có lỗi xảy ra';
        }
      }
    } catch (_) {}
    return 'Đã có lỗi xảy ra';
  }
}
