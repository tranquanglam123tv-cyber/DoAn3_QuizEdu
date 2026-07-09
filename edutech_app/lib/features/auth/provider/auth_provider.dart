import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/api/api_client.dart';
import '../../../core/auth/google_auth_helper.dart';
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
        avatarUrl: data['avatarUrl'],
        gender: data['gender'],
        dateOfBirth: data['dateOfBirth']?.toString(),
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
      final auth = AuthModel.fromJson(res.data['data']);
      await TokenStorage.save(auth.accessToken);
      currentUser = auth;
      return true;
    } catch (e) {
      debugPrint('Login error: $e');
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
      debugPrint('Register error: $e');
      error = _parseError(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loginWithGoogle() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final credential = await GoogleAuthHelper.signInWithGoogle();

      // On mobile, signInWithRedirect doesn't return credential
      // We need to get the current user after redirect
      User? googleUser = credential?.user;

      // Listen for auth state change to get user after redirect
      if (googleUser == null) {
        googleUser = await GoogleAuthHelper.getCurrentUser();
      }

      if (googleUser == null) {
        error = 'Đã hủy đăng nhập Google';
        return false;
      }

      final idToken = await googleUser.getIdToken();
      if (idToken == null) {
        error = 'Không lấy được Google token';
        return false;
      }

      final res = await ApiClient.dio.post(
        '/auth/google',
        data: {'idToken': idToken},
      );
      final auth = AuthModel.fromJson(res.data['data']);
      await TokenStorage.save(auth.accessToken);
      currentUser = auth;
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Google Firebase auth error: ${e.code} - ${e.message}');
      error = 'Đăng nhập Google thất bại: ${e.message}';
      return false;
    } catch (e) {
      debugPrint('Google login error: $e');
      error = _parseError(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await TokenStorage.delete();
    await GoogleAuthHelper.signOut();
    currentUser = null;
    notifyListeners();
  }

  void updateCurrentUser({
    String? fullName,
    String? avatarUrl,
    String? gender,
    String? dateOfBirth,
  }) {
    if (currentUser == null) return;
    currentUser = AuthModel(
      accessToken: currentUser!.accessToken,
      fullName: fullName ?? currentUser!.fullName,
      email: currentUser!.email,
      role: currentUser!.role,
      avatarUrl: avatarUrl ?? currentUser!.avatarUrl,
      gender: gender ?? currentUser!.gender,
      dateOfBirth: dateOfBirth ?? currentUser!.dateOfBirth,
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
